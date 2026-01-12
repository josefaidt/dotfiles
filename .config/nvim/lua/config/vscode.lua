---@module 'config.vscode'
---VSCode-specific configuration
if vim.g.vscode then
	-- VSCode extension
	local vscode = require("vscode-neovim")
	---Set vscode as default notifier
	---@diagnostic disable-next-line: duplicate-set-field
	vim.notify = vscode.notify

	vim.keymap.set("n", "<leader>w", function()
		vscode.call("workbench.action.files.save")
	end)
	vim.keymap.set("n", "<leader>m", function()
		vscode.call("editor.action.commentLine")
	end)
	vim.keymap.set("v", "<leader>m", function()
		vscode.call("editor.action.commentLine")
	end)
end
