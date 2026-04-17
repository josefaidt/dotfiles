---@module 'plugins.editor.markdown-nav'
---Telescope-based markdown heading navigator.
---
---Opens a picker showing every heading in the current buffer.  Each entry's
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

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local entry_display = require("telescope.pickers.entry_display")

	local hl_map = {
		"markdownH1",
		"markdownH2",
		"markdownH3",
		"markdownH4",
		"markdownH5",
		"markdownH6",
	}

	local displayer = entry_display.create({
		separator = "",
		items = {
			{ width = 4 }, -- "H1 " … "H6 "
			{ remaining = true },
		},
	})

	local function make_display(entry)
		local h = entry.value
		local hl = hl_map[h.level] or "Normal"
		local indent = string.rep("  ", h.level - 1)
		return displayer({
			{ "H" .. h.level .. " ", hl },
			{ indent .. h.text, hl },
		})
	end

	pickers
		.new({}, {
			prompt_title = "Markdown Headings",
			sorting_strategy = "ascending",
			finder = finders.new_table({
				results = headings,
				entry_maker = function(h)
					return {
						value = h,
						display = make_display,
						ordinal = h.path, -- fuzzy-match on full ancestor path
						lnum = h.lnum,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local sel = action_state.get_selected_entry()
					if sel then
						vim.api.nvim_win_set_cursor(0, { sel.value.lnum, 0 })
						vim.cmd("normal! zz")
					end
				end)
				return true
			end,
		})
		:find()
end

---@type LazySpec
return {
	"nvim-telescope/telescope.nvim",
	optional = true, -- piggybacks on the main telescope spec; lazy deduplicates
	keys = {
		{
			"<leader>sm",
			pick,
			ft = "markdown",
			desc = "[S]earch [M]arkdown headings",
		},
	},
}
