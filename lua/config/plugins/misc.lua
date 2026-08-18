return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("rose-pine")

			-- rose-pine's own DiagnosticVirtualText* groups set fg == bg (with a
			-- blend), which makes the diagnostic message text render invisible -
			-- same color as its own background. Its DiagnosticSign* groups already
			-- correctly link to the fg-only Diagnostic* groups; extend that same
			-- fix to the virtual text groups so inline error/warning text is
			-- actually readable.
			for _, sev in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
				vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. sev, { link = "Diagnostic" .. sev })
			end
		end,
	},

	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},

	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		end,
	},

	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({})
			vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<CR>")
		end,
	},

	{
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({})
			vim.keymap.set("n", "<leader>zz", vim.cmd.ZenMode)
		end,
	},

	{
		"laytan/cloak.nvim",
		config = function()
			require("cloak").setup({})
		end,
	},
}
