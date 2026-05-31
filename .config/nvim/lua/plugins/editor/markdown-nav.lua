---@module 'plugins.editor.markdown-nav'
---Snacks-based markdown heading navigator.
---
---Opens a picker showing every heading in the current buffer. Each entry's
---ordinal (the text you type to filter) is the full ancestor path, e.g.
---  "Intro / Setup / Prerequisites"
---so fuzzy-matching by path segments works like navigating a file tree.
---The display shows an indented tree with per-level highlight groups.
---
---Keymap: <leader>sm  (Search Markdown), active only in markdown buffers.

---@param accumulated {level:number, text:string}[] headings seen so far
---@param level number current heading level (1–6)
---@param text string heading text (without #s)
---@return string path like "Parent / Child / Heading"
local function heading_path(accumulated, level, text)
	local parts = {}
	for l = 1, level - 1 do
		for i = #accumulated, 1, -1 do
			if accumulated[i].level == l then
				table.insert(parts, accumulated[i].text)
				break
			end
		end
	end
	table.insert(parts, text)
	return table.concat(parts, " / ")
end

local function pick()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local headings = {}
	local accumulated = {}

	for lnum, line in ipairs(lines) do
		local hashes, text = line:match("^(#+)%s+(.+)$")
		if hashes and text then
			local level = #hashes
			local path = heading_path(accumulated, level, text)
			table.insert(headings, { level = level, text = text, path = path, lnum = lnum })
			table.insert(accumulated, { level = level, text = text })
		end
	end

	if #headings == 0 then
		vim.notify("No headings found in buffer", vim.log.levels.WARN)
		return
	end

	local hl_map = {
		"markdownH1",
		"markdownH2",
		"markdownH3",
		"markdownH4",
		"markdownH5",
		"markdownH6",
	}

	Snacks.picker.pick({
		source = "markdown_headings",
		title = "Markdown Headings",
		items = vim.tbl_map(function(h)
			return {
				text = h.path, -- ordinal: fuzzy-match on full ancestor path
				level = h.level,
				heading = h.text,
				-- buf + pos let the default file previewer show the doc at this heading
				buf = bufnr,
				pos = { h.lnum, 0 },
			}
		end, headings),
		format = function(item)
			local level_hl = hl_map[item.level] or "Normal"
			local indent = string.rep("  ", item.level - 1)
			local ret = {
				{ "H" .. item.level .. " ", level_hl },
				{ indent, "SnacksPickerFile" },
				{ item.text, "SnacksPickerFile" },
			}
			if item.positions then
				local offset = Snacks.picker.highlight.offset(ret)
				Snacks.picker.highlight.matches(ret, item.positions, offset)
			end
			return ret
		end,
		confirm = function(picker, item)
			picker:close()
			if item and item.pos then
				vim.api.nvim_win_set_cursor(0, { item.pos[1], item.pos[2] })
				vim.cmd("normal! zz")
			end
		end,
	})
end

---@type LazySpec
return {
	-- Standalone spec (no longer piggybacks on telescope).
	-- snacks is loaded eagerly, so we just wire up the keymap on FileType.
	"folke/snacks.nvim",
	optional = true,
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			group = vim.api.nvim_create_augroup("markdown-nav", { clear = true }),
			callback = function(args)
				vim.keymap.set("n", "<leader>sm", pick, {
					buffer = args.buf,
					desc = "Search markdown headings",
				})
			end,
		})
	end,
}
