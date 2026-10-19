---@module 'plugins.editor.persistence'
---Session save/restore. Auto-saves on quit; restored manually from
---the snacks dashboard (`s` to load last, `S` to pick).

---@return snacks.Picker[]
local function explorers()
	local ok, pickers = pcall(function()
		return Snacks.picker.get({ source = "explorer" })
	end)
	return ok and pickers or {}
end

---@type LazySpec
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	---@type Persistence.Config
	opts = {
		-- Skip auto-save when nvim was launched with file args; we only want
		-- session save/restore for "open nvim in a directory" workflows.
		need = 1,
	},
	init = function()
		-- `:mksession` can't represent the Snacks explorer (a `nofile` picker
		-- window). With the default "blank" in 'sessionoptions' it gets saved as
		-- an empty `enew` split, which is what shows up after a restore. Drop
		-- "blank", and persist a global flag ('globals' saves uppercase-initial
		-- g: vars) so we can reopen the explorer ourselves on load.
		vim.opt.sessionoptions:remove("blank")
		vim.opt.sessionoptions:append("globals")

		local group = vim.api.nvim_create_augroup("persistence_snacks_explorer", { clear = true })

		-- Record whether the explorer is open, then close it so it isn't written
		-- into the session file as an empty window.
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "PersistenceSavePre",
			callback = function()
				local open = explorers()
				vim.g.SnacksExplorerOpen = #open > 0 and 1 or 0
				for _, picker in ipairs(open) do
					picker:close()
				end
			end,
		})

		-- Reopen the explorer without stealing focus from the editor window.
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "PersistenceLoadPost",
			callback = function()
				if vim.g.SnacksExplorerOpen ~= 1 then
					return
				end
				vim.schedule(function()
					local win = vim.api.nvim_get_current_win()
					Snacks.explorer.open()
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_set_current_win(win)
					end
				end)
			end,
		})
	end,
}
