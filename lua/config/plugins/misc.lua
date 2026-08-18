return {
	{
		-- Not an external plugin - `dir` points at this config itself so
		-- lazy.nvim treats it as a local, non-updatable "plugin" purely to get
		-- lazy=false/priority ordering for a colorscheme. See
		-- lua/config/colors/islands-dark.lua for the actual color definitions,
		-- ported 1:1 from the user's real RustRover "Islands Dark" scheme.
		"islands-dark",
		dir = vim.fn.stdpath("config"),
		name = "islands-dark",
		lazy = false,
		priority = 1000,
		config = function()
			require("config.colors.islands-dark").setup()
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
