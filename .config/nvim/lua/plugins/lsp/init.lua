return {
	{ "mason-org/mason.nvim", { priority = 80, opts = {}, setup = function(opts) require("mason").setup(opts) end } },
	{ "mason-org/mason-lspconfig.nvim", { priority = 70 } },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim", { priority = 65 } },
	{ "b0o/schemastore.nvim", { priority = 60 } },
	{
		"neovim/nvim-lspconfig",
		{
			-- Eager, but after mason/mason-lspconfig/mason-tool-installer/schemastore/blink.cmp.
			priority = 40,
			setup = function()
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
					callback = function(event)
						require("config.keymaps_lsp").on_attach(event)

						local function client_supports_method(client, method, bufnr)
							if vim.fn.has("nvim-0.11") == 1 then
								return client:supports_method(method, bufnr)
							else
								return client.supports_method(method, { bufnr = bufnr })
							end
						end

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

					local function clean_markdown(content)
						if type(content) == "string" then
							content = content:gsub("\\%.", ".")
							content = content:gsub("\\%-", "-")
							content = content:gsub("\\%*", "*")
							content = content:gsub("\\%_", "_")
							content = content:gsub("\\%(", "(")
							content = content:gsub("\\%)", ")")
							content = content:gsub("\\%[", "[")
							content = content:gsub("\\%]", "]")
							content = content:gsub("\\%/", "/")
							content = content:gsub("\n\n\n+", "\n\n")
							return content
						elseif type(content) == "table" then
							if content.kind == "markdown" and content.value then
								content.value = clean_markdown(content.value)
							elseif content.language and content.value then
								return content
							end
							return content
						end
						return content
					end

					if type(result.contents) == "string" then
						result.contents = clean_markdown(result.contents)
					elseif type(result.contents) == "table" then
						if result.contents.kind == "markdown" then
							result.contents.value = clean_markdown(result.contents.value)
						elseif result.contents.kind == "plaintext" then
							result.contents.value = clean_markdown(result.contents.value)
						elseif vim.islist(result.contents) then
							for i, item in ipairs(result.contents) do
								result.contents[i] = clean_markdown(item)
							end
						end
					end

					return original_hover_handler(err, result, ctx, config)
				end

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
									local hover_config = vim.tbl_extend("force", config or {}, {
										border = "rounded",
										max_width = math.floor(vim.o.columns * 0.8),
										max_height = math.floor(vim.o.lines * 0.5),
									})
									pcall(vim.lsp.handlers["textDocument/hover"], err, result, ctx, hover_config)
								end
							)
						end
					end,
				})

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					group = auto_show_group,
					callback = function()
						suppressed_position = nil
					end,
				})

				_G.suppress_lsp_auto_show = function()
					local cursor = vim.api.nvim_win_get_cursor(0)
					local bufnr = vim.api.nvim_get_current_buf()
					suppressed_position = {
						bufnr = bufnr,
						line = cursor[1],
						col = cursor[2],
					}
				end

				local capabilities = require("blink.cmp").get_lsp_capabilities()
				vim.lsp.config("*", { capabilities = capabilities })

				---@type table<string, vim.lsp.Config>
				local servers = {
					rust_analyzer = {
						settings = {
							["rust-analyzer"] = {
								cargo = {
									allFeatures = true,
									loadOutDirsFromCheck = true,
									buildScripts = {
										enable = true,
									},
								},
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
						root_markers = { "tsconfig.json", "package.json" },
					},
					html = {},
					cssls = {},
					tailwindcss = {
						-- Only attach when tailwindcss is actually a project dependency.
						-- Walks up from the file reading each package.json — no subprocess.
						filetypes = {
							"html",
							"css",
							"javascript",
							"javascriptreact",
							"typescript",
							"typescriptreact",
							"svelte",
							"vue",
							"astro",
						},
						init_options = {
							userLanguages = {
								astro = "html",
							},
						},
						root_dir = function(fname)
							if type(fname) ~= "string" then
								return nil
							end
							local stop = vim.fn.getcwd()
							for _, pkg_path in
								ipairs(vim.fs.find("package.json", {
									path = vim.fs.dirname(fname),
									upward = true,
									limit = math.huge,
									stop = stop,
								}))
							do
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
					},
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
									local mason_ts = vim.fn.stdpath("data")
										.. "/mason/packages/typescript-language-server/node_modules/typescript/lib"
									return mason_ts
								end)(),
							},
						},
					},
					svelte = {},
					emmet_ls = {},
					biome = {
						cmd = {
							vim.fn.filereadable("node_modules/.bin/biome") == 1 and "node_modules/.bin/biome"
								or vim.fn.exepath("biome"),
							"lsp-proxy",
						},
						-- Only attach when a biome config exists in the project tree.
						-- Without this guard, biome attaches to every JSON file and may error
						-- when no config exists or the global config version doesn't match the CLI.
						root_markers = { "biome.json", "biome.jsonc" },
					},
					jsonls = {
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
						settings = {
							Lua = {
								completion = {
									callSnippet = "Replace",
								},
								-- Most globals (like 'vim') are handled by lazydev with proper types.
								-- Only add globals here that aren't covered by type definitions.
								diagnostics = {
									globals = { "jit" },
								},
								workspace = {
									checkThirdParty = false,
								},
								telemetry = {
									enable = false,
								},
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

				local ensure_installed = vim.tbl_keys(servers or {})
				vim.list_extend(ensure_installed, {
					"stylua",
					"ruff",
					"oxlint",
					"oxfmt",
					"markdownlint-cli2",
					"yamllint",
				})
				require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

				for server_name, server in pairs(servers) do
					vim.lsp.config(server_name, server)
				end

				require("mason-lspconfig").setup({
					ensure_installed = {},
					automatic_installation = false,
					automatic_enable = true,
				})

				vim.api.nvim_create_autocmd("BufWritePost", {
					group = vim.api.nvim_create_augroup("json-schema-reload", { clear = true }),
					pattern = "*.json",
					callback = function(args)
						local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "jsonls" })
						if #clients == 0 then
							return
						end
						-- Only restart when the file declares a $schema (changes warrant re-validation).
						local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 10, false)
						for _, line in ipairs(lines) do
							if line:match('"$schema"') then
								for _, client in ipairs(clients) do
									client:stop()
								end
								vim.defer_fn(function()
									vim.lsp.enable("jsonls")
								end, 100)
								break
							end
						end
					end,
				})
			end,
		},
	},
}
