return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("rose-pine")
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
