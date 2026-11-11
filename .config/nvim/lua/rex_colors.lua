---@module 'rex_colors'
---Colorscheme engine for themes ported from the Rex terminal (superlogical.com/rex).
---
---A palette is Rex's terminal colors (`term`: bg/fg/cursor/selection + ANSI 0–15)
---plus, optionally, Rex's interface tokens (`ui`: the `--super-*` CSS variables in
---Rex's bundled themes.json). Anything missing from `ui` is blended from `term`
---with the same ratios Rex uses, so a terminal-only palette still works.
---See colors/ember-hollow.lua for a palette.

local M = {}

local function rgb(hex)
	return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

---Mix `fg` into `bg`: amount 0 returns `bg`, 1 returns `fg`.
---@param fg string #rrggbb
---@param bg string #rrggbb
---@param amount number
---@return string
function M.mix(fg, bg, amount)
	local r1, g1, b1 = rgb(fg)
	local r2, g2, b2 = rgb(bg)
	local function channel(a, b)
		return math.floor(a * amount + b * (1 - amount) + 0.5)
	end
	return string.format("#%02x%02x%02x", channel(r1, r2), channel(g1, g2), channel(b1, b2))
end

---@class RexPalette
---@field name string colorscheme name (matches the colors/<name>.lua file)
---@field appearance "dark"|"light"
---@field term { bg: string, fg: string, cursor: string, cursor_text: string, selection: string, selection_fg: string, ansi: table<integer, string> }
---@field ui? table<string, string> Rex interface tokens (sidebar, raised, border, border_strong, scrollbar, text_secondary, text_tertiary, accent)

---Resolve a palette into the roles the highlight table uses.
---@param p RexPalette
local function roles(p)
	local t, ui, a = p.term, p.ui or {}, p.term.ansi
	local mix, bg, fg = M.mix, t.bg, t.fg
	return {
		bg = bg,
		fg = fg,
		-- Surfaces and text tiers, in Rex's own fg-into-bg ratios.
		float = ui.sidebar or mix(fg, bg, 0.035),
		raised = ui.raised or mix(fg, bg, 0.08),
		border = ui.border or mix(fg, bg, 0.17),
		border_strong = ui.border_strong or mix(fg, bg, 0.27),
		scrollbar = ui.scrollbar or mix(fg, bg, 0.35),
		text2 = ui.text_secondary or mix(fg, bg, 0.62),
		text3 = ui.text_tertiary or mix(fg, bg, 0.47),
		accent = ui.accent or t.cursor,
		cursor = t.cursor,
		cursor_text = t.cursor_text,
		selection = t.selection,
		red = a[1],
		green = a[2],
		yellow = a[3],
		blue = a[4],
		magenta = a[5],
		cyan = a[6],
		white = a[7],
		bright_yellow = a[11],
		bright_magenta = a[13],
		bright_cyan = a[14],
	}
end

---String values are links; tables are passed to nvim_set_hl.
---@return table<string, string|vim.api.keyset.highlight>
local function highlights(c)
	local mix = M.mix
	local tint = function(color, amount)
		return mix(color, c.bg, amount)
	end

	local h = {
		-- Editor UI
		Normal = { fg = c.fg, bg = c.bg },
		NormalNC = "Normal",
		NormalFloat = { fg = c.fg, bg = c.float },
		FloatBorder = { fg = c.border_strong, bg = c.float },
		FloatTitle = { fg = c.accent, bg = c.float, bold = true },
		FloatFooter = { fg = c.text3, bg = c.float },
		Cursor = { fg = c.cursor_text, bg = c.cursor },
		lCursor = "Cursor",
		CursorIM = "Cursor",
		TermCursor = "Cursor",
		CursorLine = { bg = c.float },
		CursorColumn = "CursorLine",
		ColorColumn = { bg = c.float },
		LineNr = { fg = c.border_strong },
		CursorLineNr = { fg = c.accent, bold = true },
		SignColumn = { fg = c.text3 },
		FoldColumn = { fg = c.border_strong },
		Folded = { fg = c.text2, bg = c.float },
		WinSeparator = { fg = c.border },
		EndOfBuffer = { fg = c.bg },
		NonText = { fg = c.border_strong },
		Whitespace = { fg = c.border },
		SpecialKey = { fg = c.border_strong },
		Conceal = { fg = c.text3 },
		Visual = { bg = c.selection },
		VisualNOS = "Visual",
		Search = { fg = c.bg, bg = c.yellow },
		IncSearch = { fg = c.bg, bg = c.accent, bold = true },
		CurSearch = "IncSearch",
		Substitute = { fg = c.bg, bg = c.red },
		MatchParen = { fg = c.accent, bg = c.raised, bold = true },
		StatusLine = { fg = c.text2, bg = c.float },
		StatusLineNC = { fg = c.text3, bg = c.float },
		WinBar = { fg = c.text2 },
		WinBarNC = { fg = c.text3 },
		TabLine = { fg = c.text3, bg = c.float },
		TabLineFill = { bg = c.float },
		TabLineSel = { fg = c.fg, bg = c.bg, bold = true },
		Pmenu = { fg = c.fg, bg = c.float },
		PmenuSel = { bg = c.selection, bold = true },
		PmenuKind = { fg = c.magenta, bg = c.float },
		PmenuKindSel = { fg = c.magenta, bg = c.selection },
		PmenuExtra = { fg = c.text3, bg = c.float },
		PmenuExtraSel = { fg = c.text2, bg = c.selection },
		PmenuSbar = { bg = c.raised },
		PmenuThumb = { bg = c.scrollbar },
		PmenuMatch = { fg = c.accent, bold = true },
		PmenuMatchSel = { fg = c.accent, bg = c.selection, bold = true },
		WildMenu = "PmenuSel",
		MsgSeparator = { fg = c.border, bg = c.float },
		ModeMsg = { fg = c.fg, bold = true },
		MoreMsg = { fg = c.green },
		Question = { fg = c.cyan },
		ErrorMsg = { fg = c.red },
		WarningMsg = { fg = c.yellow },
		Title = { fg = c.accent, bold = true },
		Directory = { fg = c.blue },
		QuickFixLine = { bg = c.selection },
		SpellBad = { sp = c.red, undercurl = true },
		SpellCap = { sp = c.yellow, undercurl = true },
		SpellLocal = { sp = c.cyan, undercurl = true },
		SpellRare = { sp = c.magenta, undercurl = true },
		DiffAdd = { bg = tint(c.green, 0.14) },
		DiffChange = { bg = tint(c.blue, 0.10) },
		DiffDelete = { fg = tint(c.red, 0.45), bg = tint(c.red, 0.14) },
		DiffText = { bg = tint(c.blue, 0.30) },
		Added = { fg = c.green },
		Changed = { fg = c.blue },
		Removed = { fg = c.red },

		-- Syntax: keywords red (italic), functions yellow, types cyan, strings green,
		-- constants magenta, properties blue; the orange accent marks UI focus.
		Comment = { fg = c.text3, italic = true },
		Constant = { fg = c.magenta },
		String = { fg = c.green },
		Character = "String",
		Number = { fg = c.magenta },
		Boolean = { fg = c.magenta },
		Float = "Number",
		Identifier = { fg = c.fg },
		Function = { fg = c.yellow },
		Statement = { fg = c.red, italic = true },
		Conditional = "Statement",
		Repeat = "Statement",
		Label = { fg = c.red },
		Operator = { fg = c.white },
		Keyword = { fg = c.red, italic = true },
		Exception = "Statement",
		PreProc = { fg = c.bright_magenta },
		Include = "Keyword",
		Define = "PreProc",
		Macro = "PreProc",
		PreCondit = "PreProc",
		Type = { fg = c.cyan },
		StorageClass = "Keyword",
		Structure = "Type",
		Typedef = "Type",
		Special = { fg = c.accent },
		SpecialChar = { fg = c.bright_cyan },
		Tag = { fg = c.red },
		Delimiter = { fg = c.text2 },
		SpecialComment = { fg = c.text2, italic = true },
		Debug = { fg = c.yellow },
		Underlined = { fg = c.blue, underline = true },
		Ignore = { fg = c.text3 },
		Error = { fg = c.red },
		Todo = { fg = c.bg, bg = c.accent, bold = true },

		-- Treesitter
		["@variable"] = { fg = c.fg },
		["@variable.builtin"] = { fg = c.bright_magenta, italic = true },
		["@variable.parameter"] = { fg = c.white },
		["@variable.parameter.builtin"] = "@variable.builtin",
		["@variable.member"] = { fg = c.blue },
		["@property"] = { fg = c.blue },
		["@constant"] = "Constant",
		["@constant.builtin"] = { fg = c.magenta, italic = true },
		["@constant.macro"] = "Macro",
		["@module"] = { fg = c.bright_cyan },
		["@module.builtin"] = "@module",
		["@label"] = "Label",
		["@string"] = "String",
		["@string.documentation"] = "String",
		["@string.escape"] = "SpecialChar",
		["@string.regexp"] = "SpecialChar",
		["@string.special"] = "SpecialChar",
		["@string.special.symbol"] = { fg = c.magenta },
		["@string.special.url"] = { fg = c.blue, underline = true },
		["@character"] = "Character",
		["@character.special"] = "SpecialChar",
		["@number"] = "Number",
		["@number.float"] = "Float",
		["@boolean"] = "Boolean",
		["@type"] = "Type",
		["@type.builtin"] = { fg = c.cyan, italic = true },
		["@type.definition"] = "Type",
		["@attribute"] = { fg = c.bright_yellow },
		["@attribute.builtin"] = "@attribute",
		["@function"] = "Function",
		["@function.builtin"] = { fg = c.bright_yellow },
		["@function.call"] = "Function",
		["@function.macro"] = "Macro",
		["@function.method"] = "Function",
		["@function.method.call"] = "Function",
		["@constructor"] = { fg = c.cyan },
		["@operator"] = "Operator",
		["@keyword"] = "Keyword",
		["@keyword.coroutine"] = "Keyword",
		["@keyword.function"] = "Keyword",
		["@keyword.operator"] = "Keyword",
		["@keyword.import"] = "Keyword",
		["@keyword.type"] = "Keyword",
		["@keyword.modifier"] = "Keyword",
		["@keyword.repeat"] = "Keyword",
		["@keyword.return"] = "Keyword",
		["@keyword.debug"] = "Debug",
		["@keyword.exception"] = "Keyword",
		["@keyword.conditional"] = "Keyword",
		["@keyword.conditional.ternary"] = "Operator",
		["@keyword.directive"] = "PreProc",
		["@keyword.directive.define"] = "PreProc",
		["@punctuation.delimiter"] = "Delimiter",
		["@punctuation.bracket"] = { fg = c.text2 },
		["@punctuation.special"] = { fg = c.accent },
		["@comment"] = "Comment",
		["@comment.documentation"] = "Comment",
		["@comment.error"] = { fg = c.bg, bg = c.red, bold = true },
		["@comment.warning"] = { fg = c.bg, bg = c.yellow, bold = true },
		["@comment.todo"] = "Todo",
		["@comment.note"] = { fg = c.bg, bg = c.blue, bold = true },
		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.strikethrough"] = { strikethrough = true },
		["@markup.underline"] = { underline = true },
		["@markup.heading"] = "Title",
		["@markup.heading.1"] = { fg = c.accent, bold = true },
		["@markup.heading.2"] = { fg = c.yellow, bold = true },
		["@markup.heading.3"] = { fg = c.green, bold = true },
		["@markup.heading.4"] = { fg = c.cyan, bold = true },
		["@markup.heading.5"] = { fg = c.blue, bold = true },
		["@markup.heading.6"] = { fg = c.magenta, bold = true },
		["@markup.quote"] = { fg = c.text2, italic = true },
		["@markup.math"] = { fg = c.cyan },
		["@markup.link"] = { fg = c.blue },
		["@markup.link.label"] = { fg = c.blue },
		["@markup.link.url"] = { fg = c.blue, underline = true },
		["@markup.raw"] = { fg = c.bright_cyan },
		["@markup.raw.block"] = { fg = c.white },
		["@markup.list"] = { fg = c.accent },
		["@markup.list.checked"] = { fg = c.green },
		["@markup.list.unchecked"] = { fg = c.text3 },
		["@diff.plus"] = "Added",
		["@diff.minus"] = "Removed",
		["@diff.delta"] = "Changed",
		["@tag"] = "Tag",
		["@tag.builtin"] = "Tag",
		["@tag.attribute"] = { fg = c.blue },
		["@tag.delimiter"] = { fg = c.text2 },

		-- LSP
		LspReferenceText = { bg = c.raised },
		LspReferenceRead = "LspReferenceText",
		LspReferenceWrite = { bg = c.raised, underline = true },
		LspInlayHint = { fg = c.text3, italic = true },
		LspCodeLens = { fg = c.text3 },
		LspCodeLensSeparator = { fg = c.border_strong },
		LspSignatureActiveParameter = { fg = c.accent, bold = true, underline = true },

		-- Diagnostics
		DiagnosticError = { fg = c.red },
		DiagnosticWarn = { fg = c.yellow },
		DiagnosticInfo = { fg = c.blue },
		DiagnosticHint = { fg = c.cyan },
		DiagnosticOk = { fg = c.green },
		DiagnosticVirtualTextError = { fg = c.red, bg = tint(c.red, 0.10) },
		DiagnosticVirtualTextWarn = { fg = c.yellow, bg = tint(c.yellow, 0.10) },
		DiagnosticVirtualTextInfo = { fg = c.blue, bg = tint(c.blue, 0.10) },
		DiagnosticVirtualTextHint = { fg = c.cyan, bg = tint(c.cyan, 0.10) },
		DiagnosticVirtualTextOk = { fg = c.green, bg = tint(c.green, 0.10) },
		DiagnosticUnderlineError = { sp = c.red, undercurl = true },
		DiagnosticUnderlineWarn = { sp = c.yellow, undercurl = true },
		DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
		DiagnosticUnderlineHint = { sp = c.cyan, undercurl = true },
		DiagnosticUnderlineOk = { sp = c.green, undercurl = true },
		DiagnosticUnnecessary = { fg = c.text3 },
		DiagnosticDeprecated = { sp = c.text3, strikethrough = true },

		-- gitsigns / git-blame
		GitSignsAdd = "Added",
		GitSignsChange = "Changed",
		GitSignsDelete = "Removed",
		GitSignsCurrentLineBlame = { fg = c.text3, italic = true },

		-- blink.cmp
		BlinkCmpMenu = "Pmenu",
		BlinkCmpMenuBorder = { fg = c.border_strong, bg = c.float },
		BlinkCmpMenuSelection = "PmenuSel",
		BlinkCmpScrollBarThumb = "PmenuThumb",
		BlinkCmpScrollBarGutter = "PmenuSbar",
		BlinkCmpLabel = { fg = c.fg },
		BlinkCmpLabelMatch = { fg = c.accent, bold = true },
		BlinkCmpLabelDeprecated = { fg = c.text3, strikethrough = true },
		BlinkCmpLabelDetail = { fg = c.text3 },
		BlinkCmpLabelDescription = { fg = c.text3 },
		BlinkCmpSource = { fg = c.text3 },
		BlinkCmpKind = { fg = c.magenta },
		BlinkCmpGhostText = { fg = c.text3, italic = true },
		BlinkCmpDoc = "NormalFloat",
		BlinkCmpDocBorder = "FloatBorder",
		BlinkCmpDocSeparator = { fg = c.border, bg = c.float },
		BlinkCmpSignatureHelp = "NormalFloat",
		BlinkCmpSignatureHelpBorder = "FloatBorder",
		BlinkCmpSignatureHelpActiveParameter = "LspSignatureActiveParameter",

		-- snacks (picker, explorer, indent)
		SnacksPickerMatch = { fg = c.accent, bold = true },
		SnacksPickerPrompt = { fg = c.accent },
		SnacksPickerTree = { fg = c.border },
		SnacksIndent = { fg = c.border },
		SnacksIndentScope = { fg = c.border_strong },

		-- noice
		NoiceCmdlinePopupBorder = { fg = c.accent },
		NoiceCmdlinePopupTitle = { fg = c.accent, bold = true },
		NoiceCmdlineIcon = { fg = c.accent },
		NoiceCmdlinePopupBorderSearch = { fg = c.yellow },
		NoiceCmdlineIconSearch = { fg = c.yellow },
		NoiceConfirmBorder = { fg = c.border_strong },

		-- nvim-notify (per-level colors below)
		NotifyBackground = { bg = c.bg },

		-- mini.statusline
		MiniStatuslineModeNormal = { fg = c.bg, bg = c.accent, bold = true },
		MiniStatuslineModeInsert = { fg = c.bg, bg = c.green, bold = true },
		MiniStatuslineModeVisual = { fg = c.bg, bg = c.magenta, bold = true },
		MiniStatuslineModeReplace = { fg = c.bg, bg = c.red, bold = true },
		MiniStatuslineModeCommand = { fg = c.bg, bg = c.yellow, bold = true },
		MiniStatuslineModeOther = { fg = c.bg, bg = c.cyan, bold = true },
		MiniStatuslineDevinfo = { fg = c.text2, bg = c.raised },
		MiniStatuslineFilename = { fg = c.text2, bg = c.float },
		MiniStatuslineFileinfo = { fg = c.text2, bg = c.raised },
		MiniStatuslineInactive = { fg = c.text3, bg = c.float },

		-- which-key
		WhichKey = { fg = c.accent },
		WhichKeyGroup = { fg = c.blue },
		WhichKeyDesc = { fg = c.fg },
		WhichKeySeparator = { fg = c.text3 },
		WhichKeyValue = { fg = c.text3 },
		WhichKeyNormal = "NormalFloat",
		WhichKeyBorder = "FloatBorder",
		WhichKeyTitle = "FloatTitle",

		-- flash
		FlashLabel = { fg = c.bg, bg = c.red, bold = true },
		FlashBackdrop = { fg = c.text3 },
	}

	local notify_levels = { ERROR = c.red, WARN = c.yellow, INFO = c.blue, DEBUG = c.text3, TRACE = c.magenta }
	for level, color in pairs(notify_levels) do
		h["Notify" .. level .. "Border"] = { fg = color }
		h["Notify" .. level .. "Icon"] = { fg = color }
		h["Notify" .. level .. "Title"] = { fg = color, bold = true }
	end

	local blink_kinds = {
		Text = "Delimiter",
		Method = "Function",
		Function = "Function",
		Constructor = "@constructor",
		Field = "@variable.member",
		Variable = "@variable",
		Class = "Type",
		Interface = "Type",
		Module = "@module",
		Property = "@property",
		Unit = "Number",
		Value = "Number",
		Enum = "Type",
		Keyword = "Keyword",
		Snippet = "Special",
		Color = "Special",
		File = "Directory",
		Reference = "Special",
		Folder = "Directory",
		EnumMember = "Constant",
		Constant = "Constant",
		Struct = "Type",
		Event = "Special",
		Operator = "Operator",
		TypeParameter = "Type",
	}
	for kind, link in pairs(blink_kinds) do
		h["BlinkCmpKind" .. kind] = link
	end

	return h
end

---Apply a palette as the current colorscheme. Call from colors/<name>.lua.
---@param p RexPalette
function M.load(p)
	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.termguicolors = true
	vim.o.background = p.appearance
	vim.g.colors_name = p.name

	for group, spec in pairs(highlights(roles(p))) do
		vim.api.nvim_set_hl(0, group, type(spec) == "string" and { link = spec } or spec)
	end
	for i = 0, 15 do
		vim.g["terminal_color_" .. i] = p.term.ansi[i]
	end
end

return M
