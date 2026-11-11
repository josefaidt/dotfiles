-- Ember Hollow, ported from the Rex terminal's built-in theme (id "ember-hollow").
-- Colors are copied exactly from Rex Beta's bundled themes.json
-- (Rex Beta.app/Contents/Resources/SuperUI_SuperDesignTokens.bundle/.../themes.json):
-- `term` is the theme's terminal palette, `ui` its `--super-*` interface tokens.
-- Highlight mapping lives in lua/rex_colors.lua.
require("rex_colors").load({
	name = "ember-hollow",
	appearance = "dark",
	term = {
		bg = "#171210",
		fg = "#e0cfc4",
		cursor = "#f0955c",
		cursor_text = "#171210",
		selection = "#47302a",
		selection_fg = "#f3e8e0",
		ansi = {
			[0] = "#241b17",
			"#e06c4f", -- 1 red
			"#a3b06a", -- 2 green
			"#e8a75a", -- 3 yellow
			"#8e9fb3", -- 4 blue
			"#c98a8e", -- 5 magenta
			"#8fb0a2", -- 6 cyan
			"#c3b3a8", -- 7 white
			"#6b5a50", -- 8 bright black
			"#f08767", -- 9 bright red
			"#bcc985", -- 10 bright green
			"#f5bf77", -- 11 bright yellow
			"#a8b9cc", -- 12 bright blue
			"#dda4a7", -- 13 bright magenta
			"#a9c9ba", -- 14 bright cyan
			"#f3e8e0", -- 15 bright white
		},
	},
	ui = {
		sidebar = "#1e1917", -- --super-sidebar
		raised = "#272220", -- --super-raised
		border = "#39322f", -- --super-border
		border_strong = "#4e4641", -- --super-border-strong
		scrollbar = "#5d534e", -- --super-scrollbar-hover
		text_secondary = "#94877f", -- --super-text-secondary
		text_tertiary = "#756a64", -- --super-text-tertiary
		accent = "#f0955c", -- --super-accent
	},
})
