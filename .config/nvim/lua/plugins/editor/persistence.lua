---@module 'plugins.editor.persistence'
---Session save/restore. Auto-saves on quit; restored manually from
---the alpha dashboard (`s` to load last, `S` to pick).

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
}
