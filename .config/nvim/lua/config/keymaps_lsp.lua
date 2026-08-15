---@module 'config.keymaps_lsp'
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
	---@param opts? vim.keymap.set.Opts Extra options merged into the mapping
	local map = function(keys, func, desc, mode, opts)
		mode = mode or "n"
		vim.keymap.set(
			mode,
			keys,
			func,
			vim.tbl_extend("force", { buffer = event.buf, desc = "LSP: " .. desc }, opts or {})
		)
	end

	-- Navigation uses LazyVim's letters (gd/gD/gr/gI/gy) rather than Neovim's
	-- native gr* prefix. `gr` is <nowait> so it fires without waiting on a longer
	-- match — which also shadows the built-in grn/gra/grr/gri/grt, so rename and
	-- code action live on <leader>cr / <leader>ca below.

	-- Jump to the definition of the word under your cursor.
	map("gd", function()
		Snacks.picker.lsp_definitions()
	end, "Goto definition")

	-- WARN: This is not Goto Definition, this is Goto Declaration (e.g. C header).
	map("gD", function()
		Snacks.picker.lsp_declarations()
	end, "Goto declaration")

	-- Find references for the word under your cursor.
	map("gr", function()
		Snacks.picker.lsp_references()
	end, "References", "n", { nowait = true })

	-- Jump to the implementation of the word under your cursor.
	map("gI", function()
		Snacks.picker.lsp_implementations()
	end, "Goto implementation")

	-- Jump to the type of the word under your cursor.
	map("gy", function()
		Snacks.picker.lsp_type_definitions()
	end, "Goto t[y]pe definition")

	-- Rename the symbol under your cursor.
	map("<leader>cr", vim.lsp.buf.rename, "Rename")

	-- Execute a code action.
	map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })

	-- Fuzzy find all symbols in the current document.
	local lsp_symbols = function()
		Snacks.picker.lsp_symbols()
	end
	map("<leader>ss", lsp_symbols, "LSP symbols")
	-- `gO` is Neovim's native document-symbol key; keep it pointed at the picker.
	map("gO", lsp_symbols, "Document symbols")

	-- Fuzzy find all symbols across the workspace.
	map("<leader>sS", function()
		Snacks.picker.lsp_workspace_symbols()
	end, "LSP workspace symbols")

	-- Show functions/methods that call the symbol under your cursor.
	map("gai", function()
		Snacks.picker.lsp_incoming_calls()
	end, "Incoming calls")

	-- Show functions/methods called by the symbol under your cursor.
	map("gao", function()
		Snacks.picker.lsp_outgoing_calls()
	end, "Outgoing calls")

	-- Show hover documentation (like hovering in VSCode)
	-- Custom hover that suppresses "No information available" when another client
	-- already returned content (e.g. ts_ls + biome both attached to the same buffer).
	-- Routes the result through noice's on_hover so the views.hover styling applies;
	-- vim.lsp.handlers["textDocument/hover"] is the vanilla handler and bypasses noice.
	map("K", function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients == 0 then
			return
		end
		local ok, noice_hover = pcall(require, "noice.lsp.hover")
		local handler = ok and noice_hover.on_hover or vim.lsp.handlers["textDocument/hover"]
		local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
		local got_content = false
		local pending = #clients
		for _, client in ipairs(clients) do
			client:request("textDocument/hover", params, function(err, result, ctx, config)
				pending = pending - 1
				if not err and result and result.contents then
					got_content = true
					handler(err, result, ctx, config)
				elseif pending == 0 and not got_content then
					vim.notify("No information available", vim.log.levels.INFO)
				end
			end, 0)
		end
	end, "Hover Documentation")

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
			end, "Toggle inlay hints")
		end
	end
end

return M
