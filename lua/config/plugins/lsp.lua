return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
		"j-hui/fidget.nvim",
	},
	config = function()
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		require("luasnip.loaders.from_vscode").lazy_load()
		require("fidget").setup({})
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"rust_analyzer",
				"vtsls",
				"eslint",
				"powershell_es",
			},
			handlers = {
				function(server_name) -- default handler
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,

				["powershell_es"] = function()
					local lspconfig = require("lspconfig")
					local mason_registry = require("mason-registry")
					local bundle_path = mason_registry.get_package("powershell-editor-services"):get_install_path()
					lspconfig.powershell_es.setup({
						capabilities = capabilities,
						bundle_path = bundle_path,
					})
				end,
			},
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
		})

		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		vim.keymap.set("n", "gd", vim.lsp.buf.definition)
		vim.keymap.set("n", "K", vim.lsp.buf.hover)
		vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol)
		vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_next)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_prev)
		vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action)
		vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references)
		vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename)
		vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help)
	end,
}
