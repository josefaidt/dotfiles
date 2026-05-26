---@module 'config.pack'
---vim.pack-based plugin loader with lazy.nvim-style triggers.
---
---Each file under lua/plugins/{editor,lsp,ui}/ returns one of:
---  • { "user/repo" }                      -- single eager spec, no config
---  • { "user/repo", { ...config... } }    -- single spec with config
---  • { spec, spec, ... }                  -- list of specs (mixed forms)
---
---Config table fields:
---  event/ft/cmd/keys -- lazy-load triggers (string or list); omitting all → eager load
---  version           -- branch/tag/commit/vim.version.range()
---  priority          -- eager load order (higher first)
---  setup(opts)       -- called after the plugin is :packadd'd
---  opts              -- passed to setup; if setup is nil and opts is set,
---                       the loader calls require(<inferred-module>).setup(opts)
---  build(path)       -- runs on PackChanged install/update
---  enabled           -- boolean or function; falsy = skip the spec entirely

local M = {}

---@class PackSpec
---@field [1] string                                 -- "user/repo" shorthand
---@field [2]? PackConfig                            -- optional config
---@class PackConfig
---@field event? string|string[]
---@field ft? string|string[]
---@field cmd? string|string[]
---@field keys? table[]
---@field version? string|table
---@field priority? number
---@field setup? fun(opts: table?)
---@field opts? table|fun():table
---@field build? fun(path: string)
---@field enabled? boolean|fun(): boolean

---@param shorthand string
---@param config_name string?  optional override (config.name)
---@return string src, string name
local function expand(shorthand, config_name)
	local src = "https://github.com/" .. shorthand
	local name = config_name or shorthand:match("([^/]+)$"):gsub("%.git$", "")
	return src, name
end

---@param value any
---@return any[]
local function aslist(value)
	if value == nil then
		return {}
	end
	if type(value) == "table" and not vim.islist(value) then
		return { value }
	end
	if type(value) ~= "table" then
		return { value }
	end
	return value
end

---Normalize one return value (a spec, or a list of specs) into a flat list.
---@param result any
---@return PackSpec[]
local function flatten(result)
	if type(result) ~= "table" then
		return {}
	end
	-- A single spec has [1] as a string; a list-of-specs has [1] as a table.
	if type(result[1]) == "string" then
		return { result }
	end
	local out = {}
	for _, item in ipairs(result) do
		if type(item) == "table" and type(item[1]) == "string" then
			table.insert(out, item)
		end
	end
	return out
end

---@param dir string  e.g. "plugins.editor"
---@return PackSpec[]
local function collect_dir(dir)
	local rel = dir:gsub("%.", "/")
	local config_dir = vim.fn.stdpath("config")
	local pattern = config_dir .. "/lua/" .. rel .. "/*.lua"
	local files = vim.fn.glob(pattern, false, true)
	local specs = {}
	for _, file in ipairs(files) do
		local name = vim.fn.fnamemodify(file, ":t:r")
		local mod = dir .. "." .. name
		local ok, result = pcall(require, mod)
		if ok then
			vim.list_extend(specs, flatten(result))
		else
			vim.notify("pack: failed to load " .. mod .. ": " .. tostring(result), vim.log.levels.ERROR)
		end
	end
	return specs
end

---Build the runtime registry: name → { spec, config, loaded }.
---@param specs PackSpec[]
---@return table<string, {shorthand: string, name: string, config: PackConfig, loaded: boolean}>
local function index(specs)
	local registry = {}
	for _, spec in ipairs(specs) do
		local shorthand = spec[1]
		local config = spec[2] or {}
		local _, name = expand(shorthand, config.name)
		local enabled = config.enabled
		if type(enabled) == "function" then
			enabled = enabled()
		end
		if enabled == false then
			-- skip
		else
			registry[name] = {
				shorthand = shorthand,
				name = name,
				config = config,
				loaded = false,
			}
		end
	end
	return registry
end

---@param entry table
local function run_setup(entry)
	if entry.loaded then
		return
	end
	entry.loaded = true
	vim.cmd.packadd(entry.name)
	local config = entry.config
	local opts = config.opts
	if type(opts) == "function" then
		opts = opts()
	end
	if config.setup then
		config.setup(opts)
	elseif opts ~= nil then
		-- best-effort: derive module name from repo (strip .nvim/.vim suffix, dashes → underscores)
		local mod = entry.name:gsub("%.nvim$", ""):gsub("%.vim$", ""):gsub("-", "_")
		local ok, plugin = pcall(require, mod)
		if ok and type(plugin.setup) == "function" then
			plugin.setup(opts)
		end
	end
end

---@param entry table
---@param registry table<string, table>
local function register_lazy(entry, registry)
	local config = entry.config
	local function load()
		run_setup(registry[entry.name])
	end

	local events = aslist(config.event)
	if #events > 0 then
		local user_events, real_events = {}, {}
		for _, e in ipairs(events) do
			if e:sub(1, 5) == "User " then
				table.insert(user_events, e:sub(6))
			elseif e == "VeryLazy" then
				table.insert(user_events, "VeryLazy")
			else
				table.insert(real_events, e)
			end
		end
		if #real_events > 0 then
			vim.api.nvim_create_autocmd(real_events, {
				once = true,
				callback = function()
					load()
				end,
			})
		end
		if #user_events > 0 then
			vim.api.nvim_create_autocmd("User", {
				pattern = user_events,
				once = true,
				callback = function()
					load()
				end,
			})
		end
	end

	local fts = aslist(config.ft)
	if #fts > 0 then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = fts,
			once = true,
			callback = function()
				load()
			end,
		})
	end

	local cmds = aslist(config.cmd)
	for _, cmd in ipairs(cmds) do
		vim.api.nvim_create_user_command(cmd, function(args)
			vim.api.nvim_del_user_command(cmd)
			load()
			-- Re-execute the command now that the real one is registered
			local cmdline = cmd
			if args.bang then
				cmdline = cmdline .. "!"
			end
			if args.args and args.args ~= "" then
				cmdline = cmdline .. " " .. args.args
			end
			vim.cmd(cmdline)
		end, { nargs = "*", bang = true })
	end

	local keys = config.keys or {}
	for _, key in ipairs(keys) do
		local lhs = key[1]
		local rhs = key[2]
		local modes = aslist(key.mode)
		if #modes == 0 then
			modes = { "n" }
		end
		local opts = { desc = key.desc, silent = key.silent }
		vim.keymap.set(modes, lhs, function()
			-- Replace the placeholder with the real keymap, then trigger it
			for _, m in ipairs(modes) do
				pcall(vim.keymap.del, m, lhs)
			end
			load()
			-- After load(), the plugin's own keymap (if any) is now in place.
			-- Whether the spec defined `rhs` or not, simulate the keypress so
			-- the real handler runs in the correct mode.
			if type(rhs) == "function" then
				rhs()
			elseif type(rhs) == "string" then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(rhs, true, true, true), "m", false)
			else
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, true, true), "m", false)
			end
		end, opts)
	end
end

---@param registry table<string, table>
local function register_builds(registry)
	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("config-pack-build", { clear = true }),
		callback = function(ev)
			if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
				return
			end
			local entry = registry[ev.data.spec.name]
			if entry and type(entry.config.build) == "function" then
				local ok, err = pcall(entry.config.build, ev.data.path)
				if not ok then
					vim.notify("pack: build hook for " .. entry.name .. " failed: " .. tostring(err), vim.log.levels.ERROR)
				end
			end
		end,
	})
end

---Fire User VeryLazy ~50ms after VimEnter, matching lazy.nvim's behavior.
local function schedule_very_lazy()
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.defer_fn(function()
				vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
			end, 50)
		end,
	})
end

---@param dirs string[]
function M.setup(dirs)
	local all_specs = {}
	for _, dir in ipairs(dirs) do
		vim.list_extend(all_specs, collect_dir(dir))
	end

	local registry = index(all_specs)

	-- Build the vim.pack spec list (every plugin, regardless of eager/lazy).
	local pack_specs = {}
	for _, entry in pairs(registry) do
		local src = expand(entry.shorthand)
		table.insert(pack_specs, { src = src, name = entry.name, version = entry.config.version })
	end

	-- Register build hooks BEFORE add() so install hooks fire on first run.
	register_builds(registry)
	schedule_very_lazy()

	-- Install + add to runtimepath, but don't source plugin/ files yet.
	-- We control sourcing via :packadd in run_setup / register_lazy.
	vim.pack.add(pack_specs, { load = false, confirm = false })

	-- Partition into eager (no triggers) and lazy.
	local eager, lazy = {}, {}
	for _, entry in pairs(registry) do
		local c = entry.config
		local has_trigger = c.event or c.ft or c.cmd or (c.keys and #c.keys > 0)
		if has_trigger then
			table.insert(lazy, entry)
		else
			table.insert(eager, entry)
		end
	end

	-- Eager: load in priority order (higher first), default priority = 50.
	table.sort(eager, function(a, b)
		return (a.config.priority or 50) > (b.config.priority or 50)
	end)
	for _, entry in ipairs(eager) do
		local ok, err = pcall(run_setup, entry)
		if not ok then
			vim.notify("pack: setup for " .. entry.name .. " failed: " .. tostring(err), vim.log.levels.ERROR)
		end
	end

	-- Lazy: wire up triggers.
	for _, entry in ipairs(lazy) do
		register_lazy(entry, registry)
	end
end

return M
