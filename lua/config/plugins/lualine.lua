return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			options = {
				-- "auto" derives its colors from the active colorscheme's own highlight
				-- groups (Normal/Visual/etc.) rather than shipping a fixed palette, so it
				-- follows rose-pine without needing a dedicated lualine theme for it.
				theme = "auto",
				-- One statusline for the whole editor instead of one per split - the mode
				-- indicator is otherwise only visible in whichever window last had focus.
				globalstatus = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				-- lualine's "mode" component already recolors its own background per
				-- mode (NORMAL/INSERT/VISUAL/REPLACE/COMMAND all get distinct colors from
				-- the active theme) and re-renders on every mode change via its own
				-- autocmds - this is what actually fixes the "stuck on -- INSERT --"
				-- problem: that text was Neovim's `showmode` echo-area message, which
				-- only updates on specific events and isn't colored at all.
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})

		-- Redundant now that the statusline shows a live, colored mode name;
		-- `showmode`'s plain "-- INSERT --" echo-area text was the stale-looking
		-- indicator the user was actually seeing.
		vim.opt.showmode = false
	end,
}
