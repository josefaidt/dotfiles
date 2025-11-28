-- lua/plugins/session.lua
return {
	"rmagatti/auto-session",
	config = function()
		require("auto-session").setup({
			log_level = "error",
			auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
			-- auto_session_use_git_branch = true, -- separate sessions per git branch
		})
	end,
}
