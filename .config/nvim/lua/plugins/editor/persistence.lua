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
	init = function()
		local group = vim.api.nvim_create_augroup("persistence-neotree", { clear = true })

		-- Close neo-tree before the session is written. :mksession can't recreate
		-- a live neo-tree window — it would persist the buffer name only, leaving
		-- an empty "neo-tree" buffer on restore that confuses the \ keymap.
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "PersistenceSavePre",
			callback = function()
				pcall(vim.cmd, "Neotree close")
			end,
		})

		-- After restoring, wipe any orphaned neo-tree placeholder buffers and
		-- reopen the real tree. The placeholder has buftype="" and a name like
		-- "neo-tree filesystem [N]"; real neo-tree buffers have buftype="nofile".
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "PersistenceLoadPost",
			callback = function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) then
						local name = vim.api.nvim_buf_get_name(buf)
						local buftype = vim.bo[buf].buftype
						if name:match("neo%-tree") and buftype ~= "nofile" then
							pcall(vim.api.nvim_buf_delete, buf, { force = true })
						end
					end
				end
				pcall(vim.cmd, "Neotree show")
			end,
		})
	end,
}
