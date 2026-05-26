---@module 'plugins.editor.markdown-nav'
---Snacks-based markdown heading navigator. Opens a picker showing every
---heading in the current buffer; ordinal is the full ancestor path
---("Intro / Setup / Prerequisites") so fuzzy-matching by path segments
---works like navigating a file tree. Display is an indented tree with
---per-level highlight groups. Keymap: <leader>sm in markdown buffers.

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
				text = h.path,
				level = h.level,
				heading = h.text,
				lnum = h.lnum,
			}
		end, headings),
		format = function(item)
			local hl = hl_map[item.level] or "Normal"
			local indent = string.rep("  ", item.level - 1)
			return {
				{ "H" .. item.level .. " ", hl },
				{ indent .. item.heading, hl },
			}
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
				vim.cmd("normal! zz")
			end
		end,
	})
end

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

-- This file registers a keymap rather than declaring a plugin, so return an
-- empty list so config/pack.lua treats it as a no-op spec source.
return {}
