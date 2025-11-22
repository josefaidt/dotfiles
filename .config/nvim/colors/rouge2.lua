-- Rouge 2 Theme for Neovim
-- Ported from VS Code theme
-- Usage: Place in ~/.config/nvim/colors/ and run :colorscheme rouge2

-- Reset highlights
vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

-- Set theme name
vim.g.colors_name = 'rouge2'

-- Enable true color support
vim.opt.termguicolors = true

-- Theme colors (from VS Code theme definition)
local colors = {
  -- Base background and foreground
  bg = '#17182B',
  bg_alt = '#151627',
  bg_darkest = '#07070D',
  bg_light = '#5D5D6B',
  bg_lighter = '#A2A3AA',
  bg_lightest = '#E8E8EA',

  fg = '#A2A3AA',
  cursor = '#969E92',

  -- Selection
  selection_bg = '#334D51',
  accent_light = '#74888C',

  -- Rouge palette (variables, tags, entity names)
  rouge_dark = '#B26D71',
  rouge = '#C6797E',
  rouge_light = '#D7A1A5',

  -- Purple palette (keywords, operators, punctuation, storage)
  purple = '#4C4E78',
  purple_light = '#8283A1',

  -- Green palette (strings)
  green = '#969E92',
  green_light = '#B6BBB3',

  -- Grapple/yellow palette (support, attributes)
  grapple = '#DBCDAB',
  grapple_light = '#E6DCC4',

  -- Peach palette (constants, numbers, booleans)
  peach_light = '#F0B7A7',

  -- Berry palette (parameters)
  berry = '#DB6375',
  berry_dark = '#C55969',

  -- Blue palette (types)
  blue_dark = '#1B596C',
  blue = '#1E6378',

  -- ANSI terminal colors (for :terminal mode)
  ansi_black = '#5D5D6B',
  ansi_red = '#C6797E',
  ansi_green = '#969E92',
  ansi_yellow = '#DBCDAB',
  ansi_blue = '#6e94b9',
  ansi_magenta = '#4C4E78',
  ansi_cyan = '#8ab6c1',
  ansi_white = '#E8E8EA',
  ansi_bright_black = '#616274',
  ansi_bright_red = '#C6797E',
  ansi_bright_green = '#B6BBB3',
  ansi_bright_yellow = '#E6DCC4',
  ansi_bright_blue = '#98b3cd',
  ansi_bright_magenta = '#8283A1',
  ansi_bright_cyan = '#abcbd3',
  ansi_bright_white = '#E8E8EA',

  none = 'NONE',
}

-- Helper function to set highlights
local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor UI
hl('Normal', { fg = colors.fg, bg = colors.bg })
hl('NormalFloat', { fg = colors.fg, bg = colors.bg })
hl('FloatBorder', { fg = colors.ansi_bright_black, bg = colors.bg })
hl('ColorColumn', { bg = colors.bg_alt })
hl('Cursor', { fg = colors.bg, bg = colors.cursor })
hl('CursorLine', { bg = colors.bg_alt })
hl('CursorColumn', { bg = colors.bg_alt })
hl('LineNr', { fg = colors.bg_light })
hl('CursorLineNr', { fg = colors.grapple, bold = true })
hl('SignColumn', { bg = colors.bg })
hl('StatusLine', { fg = colors.fg, bg = colors.ansi_bright_black })
hl('StatusLineNC', { fg = colors.bg_light, bg = colors.bg_alt })
hl('VertSplit', { fg = colors.bg_light })
hl('WinSeparator', { fg = colors.bg_light })

-- Visual selection
hl('Visual', { bg = colors.selection_bg })
hl('VisualNOS', { bg = colors.selection_bg })

-- Search
hl('Search', { fg = colors.bg, bg = colors.grapple })
hl('IncSearch', { fg = colors.bg, bg = colors.grapple_light })
hl('CurSearch', { fg = colors.bg, bg = colors.grapple_light, bold = true })

-- Popups and menus
hl('Pmenu', { fg = colors.fg, bg = colors.bg_alt })
hl('PmenuSel', { fg = colors.bg_lightest, bg = colors.selection_bg })
hl('PmenuSbar', { bg = colors.bg_light })
hl('PmenuThumb', { bg = colors.accent_light })

-- Tabs
hl('TabLine', { fg = colors.fg, bg = colors.bg_alt })
hl('TabLineFill', { bg = colors.bg_alt })
hl('TabLineSel', { fg = colors.bg_lightest, bg = colors.bg, bold = true })

-- Folds
hl('Folded', { fg = colors.bg_light, bg = colors.bg_alt })
hl('FoldColumn', { fg = colors.bg_light, bg = colors.bg })

-- Diffs
hl('DiffAdd', { fg = colors.green, bg = colors.bg })
hl('DiffChange', { fg = colors.grapple, bg = colors.bg })
hl('DiffDelete', { fg = colors.berry, bg = colors.bg })
hl('DiffText', { fg = colors.grapple_light, bg = colors.bg, bold = true })

-- Spelling
hl('SpellBad', { sp = colors.berry, undercurl = true })
hl('SpellCap', { sp = colors.grapple, undercurl = true })
hl('SpellLocal', { sp = colors.accent_light, undercurl = true })
hl('SpellRare', { sp = colors.purple, undercurl = true })

-- Messages
hl('ErrorMsg', { fg = colors.berry, bold = true })
hl('WarningMsg', { fg = colors.grapple, bold = true })
hl('ModeMsg', { fg = colors.green, bold = true })
hl('MoreMsg', { fg = colors.accent_light })
hl('Question', { fg = colors.accent_light })

-- Syntax highlighting (following VS Code theme mappings)
hl('Comment', { fg = colors.bg_light, italic = true })
hl('Constant', { fg = colors.peach_light })
hl('String', { fg = colors.green })
hl('Character', { fg = colors.green })
hl('Number', { fg = colors.peach_light })
hl('Boolean', { fg = colors.peach_light })
hl('Float', { fg = colors.peach_light })

hl('Identifier', { fg = colors.rouge })
hl('Function', { fg = colors.rouge_light })

hl('Statement', { fg = colors.purple_light, italic = true })
hl('Conditional', { fg = colors.purple_light, italic = true })
hl('Repeat', { fg = colors.purple_light, italic = true })
hl('Label', { fg = colors.purple_light })
hl('Operator', { fg = colors.purple_light })
hl('Keyword', { fg = colors.purple_light, italic = true })
hl('Exception', { fg = colors.berry })

hl('PreProc', { fg = colors.grapple })
hl('Include', { fg = colors.purple_light, italic = true })
hl('Define', { fg = colors.purple_light })
hl('Macro', { fg = colors.grapple })
hl('PreCondit', { fg = colors.grapple })

hl('Type', { fg = colors.rouge })
hl('StorageClass', { fg = colors.purple_light, italic = true })
hl('Structure', { fg = colors.rouge })
hl('Typedef', { fg = colors.rouge })

hl('Special', { fg = colors.grapple })
hl('SpecialChar', { fg = colors.grapple })
hl('Tag', { fg = colors.rouge })
hl('Delimiter', { fg = colors.purple_light })
hl('SpecialComment', { fg = colors.bg_light, italic = true })
hl('Debug', { fg = colors.berry })

hl('Underlined', { underline = true })
hl('Ignore', { fg = colors.bg_light })
hl('Error', { fg = colors.berry, bold = true })
hl('Todo', { fg = colors.grapple, bold = true })

-- Treesitter highlights (VS Code theme mappings)
hl('@text.literal', { fg = colors.green })
hl('@text.reference', { fg = colors.rouge })
hl('@text.title', { fg = colors.rouge_dark, bold = true })
hl('@text.uri', { fg = colors.accent_light, underline = true })
hl('@text.underline', { underline = true })
hl('@text.todo', { fg = colors.grapple, bold = true })

hl('@comment', { link = 'Comment' })
hl('@punctuation', { fg = colors.purple_light })

hl('@constant', { link = 'Constant' })
hl('@constant.builtin', { fg = colors.peach_light })
hl('@constant.macro', { fg = colors.grapple })
hl('@define', { link = 'Define' })
hl('@macro', { link = 'Macro' })
hl('@string', { link = 'String' })
hl('@string.escape', { fg = colors.grapple })
hl('@string.special', { fg = colors.grapple })
hl('@character', { link = 'Character' })
hl('@character.special', { fg = colors.grapple })
hl('@number', { link = 'Number' })
hl('@boolean', { link = 'Boolean' })
hl('@float', { link = 'Float' })

hl('@function', { link = 'Function' })
hl('@function.builtin', { fg = colors.rouge_light })
hl('@function.macro', { fg = colors.grapple })
hl('@parameter', { fg = colors.berry })
hl('@method', { fg = colors.rouge_light })
hl('@field', { fg = colors.bg_lighter }) -- Object literal keys like { name: 'value' }
hl('@property', { fg = colors.rouge }) -- Property access like env.SOMETHING
hl('@variable.member', { fg = colors.rouge }) -- Modern treesitter for accessed properties
hl('@constructor', { fg = colors.rouge })

hl('@conditional', { link = 'Conditional' })
hl('@repeat', { link = 'Repeat' })
hl('@label', { link = 'Label' })
hl('@operator', { link = 'Operator' })
hl('@keyword', { link = 'Keyword' })
hl('@exception', { link = 'Exception' })

hl('@variable', { fg = colors.rouge })
hl('@variable.builtin', { fg = colors.purple_light, italic = true })
hl('@type', { link = 'Type' })
hl('@type.definition', { link = 'Typedef' })
hl('@type.builtin', { fg = colors.rouge })
hl('@storageclass', { link = 'StorageClass' })
hl('@structure', { link = 'Structure' })
hl('@namespace', { fg = colors.rouge })
hl('@include', { link = 'Include' })
hl('@preproc', { link = 'PreProc' })
hl('@debug', { link = 'Debug' })
-- HTML/JSX tags
hl('@tag', { fg = colors.rouge }) -- HTML tag names in JSX
hl('@tag.builtin', { fg = colors.rouge }) -- Built-in HTML tags (div, span, etc.)
hl('@tag.attribute', { fg = colors.grapple, italic = true })
hl('@tag.delimiter', { fg = colors.bg_light })

-- JSX/TSX specific
hl('@tag.tsx', { fg = colors.rouge }) -- JSX tags
hl('@tag.javascript', { fg = colors.rouge }) -- JSX tags in .jsx
hl('@constructor.tsx', { fg = colors.rouge }) -- Component names (uppercase) in TSX
hl('@constructor.javascript', { fg = colors.rouge }) -- Component names in JSX

-- JSON specific - keep keys grey
hl('@property.json', { fg = colors.bg_lighter })
hl('@label.json', { fg = colors.bg_lighter })
hl('@string.special.key.json', { fg = colors.bg_lighter })

-- LSP semantic tokens
hl('@lsp.type.class', { link = 'Type' })
hl('@lsp.type.decorator', { link = 'Function' })
hl('@lsp.type.enum', { link = 'Type' })
hl('@lsp.type.enumMember', { link = 'Constant' })
hl('@lsp.type.function', { link = 'Function' })
hl('@lsp.type.interface', { link = 'Type' })
hl('@lsp.type.macro', { link = 'Macro' })
hl('@lsp.type.method', { link = 'Function' })
hl('@lsp.type.namespace', { fg = colors.grapple }) -- Global objects like JSON, Math, console
hl('@lsp.type.parameter', { link = '@parameter' })
hl('@lsp.type.property', { fg = colors.rouge }) -- Accessed properties like env.SOMETHING
hl('@lsp.type.struct', { link = 'Type' })
hl('@lsp.type.type', { link = 'Type' })
hl('@lsp.type.typeParameter', { link = 'Type' })
hl('@lsp.type.variable', { link = '@variable' })

-- Additional LSP overrides for built-in globals
hl('@lsp.typemod.variable.defaultLibrary', { fg = colors.grapple })
hl('@lsp.typemod.variable.readonly', { fg = colors.grapple })
hl('@lsp.typemod.class.defaultLibrary', { fg = colors.grapple })
hl('@lsp.typemod.function.defaultLibrary', { fg = colors.rouge_light })

-- LSP diagnostics
hl('DiagnosticError', { fg = colors.berry })
hl('DiagnosticWarn', { fg = colors.grapple })
hl('DiagnosticInfo', { fg = colors.accent_light })
hl('DiagnosticHint', { fg = colors.bg_light })

hl('DiagnosticUnderlineError', { sp = colors.berry, undercurl = true })
hl('DiagnosticUnderlineWarn', { sp = colors.grapple, undercurl = true })
hl('DiagnosticUnderlineInfo', { sp = colors.accent_light, undercurl = true })
hl('DiagnosticUnderlineHint', { sp = colors.bg_light, undercurl = true })

-- Git signs
hl('GitSignsAdd', { fg = colors.green })
hl('GitSignsChange', { fg = colors.grapple })
hl('GitSignsDelete', { fg = colors.berry })

-- Telescope (popular fuzzy finder plugin)
hl('TelescopeBorder', { fg = colors.bg_light })
hl('TelescopeSelection', { bg = colors.selection_bg })
hl('TelescopeMatching', { fg = colors.grapple, bold = true })

-- nvim-tree (file explorer plugin)
hl('NvimTreeFolderName', { fg = colors.rouge })
hl('NvimTreeOpenedFolderName', { fg = colors.rouge_light })
hl('NvimTreeRootFolder', { fg = colors.purple_light, bold = true })

-- nvim-tree git status colors
hl('NvimTreeGitDirty', { fg = colors.grapple })
hl('NvimTreeGitStaged', { fg = colors.green })
hl('NvimTreeGitMerge', { fg = colors.berry })
hl('NvimTreeGitRenamed', { fg = colors.grapple })
hl('NvimTreeGitNew', { fg = colors.green })
hl('NvimTreeGitDeleted', { fg = colors.berry })
hl('NvimTreeGitIgnored', { fg = colors.bg_light })

-- neo-tree (alternative file explorer)
hl('NeoTreeGitAdded', { fg = colors.green })
hl('NeoTreeGitConflict', { fg = colors.berry })
hl('NeoTreeGitDeleted', { fg = colors.berry })
hl('NeoTreeGitIgnored', { fg = colors.bg_light })
hl('NeoTreeGitModified', { fg = colors.grapple })
hl('NeoTreeGitUnstaged', { fg = colors.grapple })
hl('NeoTreeGitUntracked', { fg = colors.green })
hl('NeoTreeGitStaged', { fg = colors.green })

-- Terminal colors (matches Ghostty config)
vim.g.terminal_color_0 = colors.ansi_black
vim.g.terminal_color_1 = colors.ansi_red
vim.g.terminal_color_2 = colors.ansi_green
vim.g.terminal_color_3 = colors.ansi_yellow
vim.g.terminal_color_4 = colors.ansi_blue
vim.g.terminal_color_5 = colors.ansi_magenta
vim.g.terminal_color_6 = colors.ansi_cyan
vim.g.terminal_color_7 = colors.ansi_white
vim.g.terminal_color_8 = colors.ansi_bright_black
vim.g.terminal_color_9 = colors.ansi_bright_red
vim.g.terminal_color_10 = colors.ansi_bright_green
vim.g.terminal_color_11 = colors.ansi_bright_yellow
vim.g.terminal_color_12 = colors.ansi_bright_blue
vim.g.terminal_color_13 = colors.ansi_bright_magenta
vim.g.terminal_color_14 = colors.ansi_bright_cyan
vim.g.terminal_color_15 = colors.ansi_bright_white