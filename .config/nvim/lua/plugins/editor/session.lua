---@module 'plugins.editor.session'
---Saves the last open buffer to a state file on exit and restores it on startup.
---Uses a virtual lazy spec so no external plugin is needed.

local state_file = vim.fn.stdpath("state") .. "/lastbuf"

---@type LazySpec
return {
	virtual = true,
	name = "last-buffer",
	lazy = false,
	init = function()
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				local file = vim.fn.expand("%:p")
				if file ~= "" and vim.fn.filereadable(file) == 1 then
					local f = io.open(state_file, "w")
					if f then
						f:write(file)
						f:close()
					end
				end
			end,
		})

		vim.api.nvim_create_autocmd("VimEnter", {
			nested = true,
			callback = function()
				-- Skip if a file was passed on the command line
				if vim.fn.argc() > 0 then
					return
				end
				vim.schedule(function()
					local f = io.open(state_file, "r")
					if f then
						local file = f:read("*l")
						f:close()
						if file and vim.fn.filereadable(file) == 1 then
							vim.cmd("edit " .. vim.fn.fnameescape(file))
							return
						end
					end
					-- No saved file — fall back to starter
					require("mini.starter").open()
				end)
			end,
		})
	end,
}
