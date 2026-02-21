---@module 'config.keymaps.lsp'
---LSP keymaps module
---These keymaps are set up when an LSP attaches to a buffer

local M = {}

---Set up LSP keymaps when LSP attaches to a buffer
---@param event {buf: integer, data: {client_id: integer}}
function M.on_attach(event)
	---Helper function to define mappings specific for LSP related items
	---@param keys string|string[] Key mapping
	---@param func function|string Function to execute or command string
	---@param desc string Description of the mapping
	---@param mode? string|string[] Mode(s) for the mapping (default: "n")
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end

	-- Rename the variable under your cursor.
	--  Most Language Servers support renaming across files, etc.
	map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

	-- Execute a code action, usually your cursor needs to be on top of an error
	-- or a suggestion from your LSP for this to activate.
	map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

	-- Find references for the word under your cursor.
	map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

	-- Jump to the implementation of the word under your cursor.
	--  Useful when your language has ways of declaring types without an actual implementation.
	map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

	-- Jump to the definition of the word under your cursor.
	--  This is where a variable was first declared, or where a function is defined, etc.
	--  To jump back, press <C-t>.
	map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

	-- WARN: This is not Goto Definition, this is Goto Declaration.
	--  For example, in C this would take you to the header.
	map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

	-- Fuzzy find all the symbols in your current document.
	--  Symbols are things like variables, functions, types, etc.
	map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

	-- Fuzzy find all the symbols in your current workspace.
	--  Similar to document symbols, except searches over your entire project.
	map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

	-- Jump to the type of the word under your cursor.
	--  Useful when you're not sure what type a variable is and you want to see
	--  the definition of its *type*, not where it was *defined*.
	map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

	-- VSCode-like diagnostic keymaps
	-- Show hover documentation (like hovering in VSCode)
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	-- Show diagnostic in floating window
	map("<leader>e", vim.diagnostic.open_float, "Show Diagnostic")
	-- Jump to next/previous diagnostic
	map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
	map("]d", vim.diagnostic.goto_next, "Next Diagnostic")

	-- Toggle inlay hints (if supported by the LSP)
	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if client then
		---This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
		---@param client vim.lsp.Client
		---@param method string LSP method name
		---@param bufnr? integer Buffer number
		---@return boolean
		local function client_supports_method(client, method, bufnr)
			if vim.fn.has("nvim-0.11") == 1 then
				return client:supports_method(method, bufnr)
			else
				return client.supports_method(method, { bufnr = bufnr })
			end
		end

		if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>uh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[U]I: Toggle Inlay [H]ints")
		end
	end
end

return M
