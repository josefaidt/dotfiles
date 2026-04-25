---@module 'plugins.lsp'
---Main LSP Configuration with Mason integration

---@type LazySpec
return {
	-- Main LSP Configuration
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		-- Mason must be loaded before its dependents so we need to set it up here.
		-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
		{ "mason-org/mason.nvim", opts = {} },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- JSON schemas for autocompletion (package.json, tsconfig.json, etc.)
		"b0o/schemastore.nvim",

		-- Useful status updates for LSP.
		-- { 'j-hui/fidget.nvim', opts = {} },

		-- Allows extra capabilities provided by blink.cmp
		"saghen/blink.cmp",
	},
	config = function()
		-- Brief aside: **What is LSP?**
		--
		-- LSP is an initialism you've probably heard, but might not understand what it is.
		--
		-- LSP stands for Language Server Protocol. It's a protocol that helps editors
		-- and language tooling communicate in a standardized fashion.
		--
		-- In general, you have a "server" which is some tool built to understand a particular
		-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
		-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
		-- processes that communicate with some "client" - in this case, Neovim!
		--
		-- LSP provides Neovim with features like:
		--  - Go to definition
		--  - Find references
		--  - Autocompletion
		--  - Symbol Search
		--  - and more!
		--
		-- Thus, Language Servers are external tools that must be installed separately from
		-- Neovim. This is where `mason` and related plugins come into play.
		--
		-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
		-- and elegantly composed help section, `:help lsp-vs-treesitter`

		--  This function gets run when an LSP attaches to a particular buffer.
		--    That is to say, every time a new file is opened that is associated with
		--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
		--    function will be executed to configure the current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				-- Load LSP keymaps from centralized keymap config
				require("config.keymaps.lsp").on_attach(event)

				---This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
				---@param client vim.lsp.Client
				---@param method string LSP method name
				---@param bufnr? integer some lsp support methods only in specific files
				---@return boolean
				local function client_supports_method(client, method, bufnr)
					if vim.fn.has("nvim-0.11") == 1 then
						return client:supports_method(method, bufnr)
					else
						return client.supports_method(method, { bufnr = bufnr })
					end
				end

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client_supports_method(
						client,
						vim.lsp.protocol.Methods.textDocument_documentHighlight,
						event.buf
					)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end
			end,
		})

		-- Highlight groups for float window borders (distinct colors per window type)
		vim.api.nvim_set_hl(0, "LspHoverBorder", { link = "DiagnosticInfo" })
		vim.api.nvim_set_hl(0, "LspDiagnosticFloatBorder", { link = "DiagnosticWarn" })

		-- Custom hover handler that cleans up markdown content
		-- This fixes issues with escaped characters and extra blank lines in LSP hover
		local original_hover_handler = vim.lsp.handlers["textDocument/hover"]
		vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
			if not result or not result.contents then
				return original_hover_handler(err, result, ctx, config)
			end

			-- Clean up markdown content by removing unnecessary escape sequences and blank lines
			local function clean_markdown(content)
				if type(content) == "string" then
					-- Remove unnecessary escape sequences common in JSON schema descriptions
					content = content:gsub("\\%.", ".") -- \. -> .
					content = content:gsub("\\%-", "-") -- \- -> -
					content = content:gsub("\\%*", "*") -- \* -> *
					content = content:gsub("\\%_", "_") -- \_ -> _
					content = content:gsub("\\%(", "(") -- \( -> (
					content = content:gsub("\\%)", ")") -- \) -> )
					content = content:gsub("\\%[", "[") -- \[ -> [
					content = content:gsub("\\%]", "]") -- \] -> ]
					content = content:gsub("\\%/", "/") -- \/ -> /

					-- Remove excessive blank lines (3+ consecutive newlines -> 2)
					content = content:gsub("\n\n\n+", "\n\n")

					return content
				elseif type(content) == "table" then
					-- Handle MarkedString[] format
					if content.kind == "markdown" and content.value then
						content.value = clean_markdown(content.value)
					elseif content.language and content.value then
						-- MarkupContent with language field (code blocks)
						-- Don't clean code blocks
						return content
					end
					return content
				end
				return content
			end

			-- Clean the contents
			if type(result.contents) == "string" then
				result.contents = clean_markdown(result.contents)
			elseif type(result.contents) == "table" then
				if result.contents.kind == "markdown" then
					result.contents.value = clean_markdown(result.contents.value)
				elseif result.contents.kind == "plaintext" then
					result.contents.value = clean_markdown(result.contents.value)
				elseif vim.islist(result.contents) then
					-- Handle array of MarkedString
					for i, item in ipairs(result.contents) do
						result.contents[i] = clean_markdown(item)
					end
				end
			end

			return original_hover_handler(err, result, ctx, config)
		end

		-- Diagnostic Config
		-- See :help vim.diagnostic.Opts
		vim.diagnostic.config({
			severity_sort = true,
			float = {
				border = "rounded",
				source = "if_many",
				header = "",
				prefix = " ",
				suffix = "",
				max_width = 80,
				max_height = 20,
				focusable = true,
				focus = false,
				scope = "cursor",
				style = "minimal",
				winhighlight = "Normal:Normal,FloatBorder:LspDiagnosticFloatBorder",
			},
			-- VSCode-like: Show underlines for all diagnostics (squiggly lines)
			underline = true,
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			-- VSCode-like: Hide inline diagnostic text, use 'gl' keymap to show in popover
			virtual_text = false,
		})

		-- Track cursor position where we manually dismissed a float
		local suppressed_position = nil

		-- Auto-show diagnostics or hover info when cursor rests on a symbol.
		-- Gated by vim.g.lsp_auto_hover (default off; toggle with <leader>ush).
		vim.g.lsp_auto_hover = false
		local auto_show_group = vim.api.nvim_create_augroup("auto-show-diagnostics", { clear = true })
		vim.api.nvim_create_autocmd({ "CursorHold" }, {
			group = auto_show_group,
			callback = function()
				if not vim.g.lsp_auto_hover then
					return
				end
				local cursor = vim.api.nvim_win_get_cursor(0)
				local bufnr = vim.api.nvim_get_current_buf()

				-- Don't auto-show if cursor is at the position where we dismissed
				if suppressed_position then
					if
						suppressed_position.bufnr == bufnr
						and suppressed_position.line == cursor[1]
						and suppressed_position.col == cursor[2]
					then
						return
					end
				end

				local diagnostics = vim.diagnostic.get(0, { lnum = cursor[1] - 1 })
				if #diagnostics > 0 then
					local opts = {
						focusable = false,
						close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
						border = "rounded",
						source = "if_many",
						prefix = " ",
						scope = "cursor",
						winhighlight = "Normal:Normal,FloatBorder:LspDiagnosticFloatBorder",
					}
					vim.diagnostic.open_float(nil, opts)
				else
					-- Silently request hover — suppress "No information available" spam
					-- (vim.lsp.buf.hover() notifies once per attached client that returns nothing)
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					if #clients == 0 then
						return
					end
					vim.lsp.buf_request(
						0,
						"textDocument/hover",
						vim.lsp.util.make_position_params(0, clients[1].offset_encoding),
						function(err, result, ctx, config)
							if err or not result or not result.contents then
								return
							end
							-- Provide explicit config to prevent width calculation errors
							local hover_config = vim.tbl_extend("force", config or {}, {
								border = "rounded",
								max_width = math.floor(vim.o.columns * 0.8),
								max_height = math.floor(vim.o.lines * 0.5),
							})
							-- Silently catch width calculation errors for edge case hover content
							pcall(vim.lsp.handlers["textDocument/hover"], err, result, ctx, hover_config)
						end
					)
				end
			end,
		})

		-- Clear suppression when cursor moves
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = auto_show_group,
			callback = function()
				suppressed_position = nil
			end,
		})

		-- Expose function to suppress auto-show at current position (called from Esc keymap)
		_G.suppress_lsp_auto_show = function()
			local cursor = vim.api.nvim_win_get_cursor(0)
			local bufnr = vim.api.nvim_get_current_buf()
			suppressed_position = {
				bufnr = bufnr,
				line = cursor[1],
				col = cursor[2],
			}
		end

		-- LSP servers and clients are able to communicate to each other what features they support.
		--  By default, Neovim doesn't support everything that is in the LSP specification.
		--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
		--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Set global capabilities for all servers using the new vim.lsp.config API
		vim.lsp.config("*", { capabilities = capabilities })

		---Enable the following language servers
		---Feel free to add/remove any LSPs that you want here. They will automatically be installed.
		---
		---Add any additional override configuration in the following tables. Available keys are:
		--- - cmd (table): Override the default command used to start the server
		--- - filetypes (table): Override the default list of associated filetypes for the server
		--- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		--- - settings (table): Override the default settings passed when initializing the server.
		---       For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
		--- - root_markers (table): Files/directories to search for when determining project root (replaces root_dir patterns)
		---@type table<string, vim.lsp.Config>
		local servers = {
			-- clangd = {},
			-- gopls = {},
			-- pyright = {},
			rust_analyzer = {
				-- Rust language server configuration
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = {
								enable = true,
							},
						},
						-- Add clippy lints for Rust.
						checkOnSave = {
							allFeatures = true,
							command = "clippy",
							extraArgs = { "--no-deps" },
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
					},
				},
			},
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			--
			-- But for many setups, the LSP (`ts_ls`) will work just fine
			-- ts_ls = {},
			--
			ts_ls = {
				-- Explicitly exclude astro — astro-ls provides its own TS support via
				-- its TypeScript plugin. Having ts_ls also attach causes false "unused
				-- import" diagnostics because ts_ls only sees the frontmatter script
				-- block and not the template.
				filetypes = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
				},
				-- Handle monorepo setups with symlinked node_modules
				-- Use root_markers instead of root_dir function for simple pattern matching
				root_markers = { "tsconfig.json", "package.json" },
			},
			html = {}, -- HTML
			cssls = {}, -- CSS
			tailwindcss = {
				-- Only attach when tailwindcss is actually a project dependency.
				-- Walks up from the file reading each package.json — no subprocess.
				root_dir = function(fname)
					if type(fname) ~= "string" then
						return nil
					end
					local stop = vim.fn.getcwd()
					for _, pkg_path in ipairs(vim.fs.find("package.json", {
						path = vim.fs.dirname(fname),
						upward = true,
						limit = math.huge,
						stop = stop,
					})) do
						local f = io.open(pkg_path, "r")
						if f then
							local content = f:read("*a")
							f:close()
							if content:find('"tailwindcss"') then
								return vim.fs.dirname(pkg_path)
							end
						end
					end
					return nil
				end,
			}, -- Tailwind
			astro = {
				-- Point the Astro LSP at the project-local TypeScript SDK so it can
				-- resolve component usage in templates from the start, preventing
				-- false "unused variable" warnings on frontmatter imports.
				init_options = {
					typescript = {
						tsdk = (function()
							local project_ts = vim.fn.finddir("node_modules/typescript/lib", vim.fn.getcwd() .. ";")
							if project_ts ~= "" then
								return project_ts
							end
							-- fallback to Mason-installed typescript-language-server's bundled tsc
							local mason_ts = vim.fn.stdpath("data")
								.. "/mason/packages/typescript-language-server/node_modules/typescript/lib"
							return mason_ts
						end)(),
					},
				},
			}, -- Astro
			svelte = {}, -- Svelte
			emmet_ls = {}, -- Emmet for HTML/CSS
			biome = {
				-- Use project-local biome when available, fallback to Mason-installed version
				cmd = {
					vim.fn.filereadable("node_modules/.bin/biome") == 1 and "node_modules/.bin/biome"
						or vim.fn.exepath("biome"),
					"lsp-proxy",
				},
				-- Only attach when a biome config exists in the project tree.
				-- Without this guard, biome attaches to every JSON file and may error
				-- when no config exists or the global config version doesn't match the CLI.
				-- Use root_markers instead of root_dir function for simple pattern matching
				root_markers = { "biome.json", "biome.jsonc" },
			},
			jsonls = {
				-- JSON language server with schema support
				-- Disable formatting since we use biome/prettier via conform.nvim
				on_attach = function(client, bufnr)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end,
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			},

			yamlls = {
			-- YAML language server with schema support
			settings = {
				yaml = {
					schemaStore = {
						-- Disable built-in schemaStore so schemastore.nvim can provide schemas
						enable = false,
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
					validate = true,
					hover = true,
					completion = true,
				},
			},
		},

		lua_ls = {
				-- cmd = { ... },
				-- filetypes = { ... },
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						-- Most globals (like 'vim') are handled by lazydev with proper types
						-- Only add globals here that aren't covered by type definitions
						diagnostics = {
							-- LuaJIT globals that don't have type defs
							globals = { "jit" },
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- disable = { 'missing-fields' },
						},
						workspace = {
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
						-- Improve type inference
						hint = {
							enable = true,
							setType = false,
							paramType = true,
							paramName = "Disable",
							semicolon = "Disable",
							arrayIndex = "Disable",
						},
					},
				},
			},
		}

		-- Ensure the servers and tools above are installed
		--
		-- To check the current status of installed tools and/or manually install
		-- other tools, you can run
		--    :Mason
		--
		-- You can press `g?` for help in this menu.
		--
		-- `mason` had to be setup earlier: to configure its options see the
		-- `dependencies` table for `nvim-lspconfig` above.
		--
		-- You can add other tools here that you want Mason to install
		-- for you, so that they are available from within Neovim.
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format Lua code
			"ruff", -- Python linter and formatter
			"oxlint", -- Fast JS/TS linter (default when no eslint/biome config)
			"oxfmt", -- Fast JS/TS formatter (default when no biome/prettier config)
			"markdownlint-cli2", -- Markdown linter with GFM support
			"yamllint", -- YAML linter
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		-- Configure all servers using the new vim.lsp.config API
		for server_name, server in pairs(servers) do
			vim.lsp.config(server_name, server)
		end

		-- Setup mason-lspconfig with automatic_enable to auto-start configured servers
		require("mason-lspconfig").setup({
			ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
			automatic_installation = false,
			automatic_enable = true,
		})

		-- Auto-restart jsonls when $schema is updated in JSON files
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = vim.api.nvim_create_augroup("json-schema-reload", { clear = true }),
			pattern = "*.json",
			callback = function(args)
				local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "jsonls" })
				if #clients > 0 then
					-- Check first 10 lines for $schema
					local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 10, false)
					for _, line in ipairs(lines) do
						if line:match('"$schema"') then
							vim.cmd("LspRestart jsonls")
							-- Silently restart without notification
							break
						end
					end
				end
			end,
		})
	end,
}
