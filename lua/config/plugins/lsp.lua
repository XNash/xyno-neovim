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

		-- mason-lspconfig (current version) has no `handlers` option anymore -
		-- it just installs servers and calls vim.lsp.enable() for each one
		-- automatically. Per-server capabilities/settings go through the
		-- native vim.lsp.config() API instead, which deep-merges with
		-- nvim-lspconfig's own defaults for that server.
		vim.lsp.config("*", { capabilities = capabilities })

		vim.lsp.config("rust_analyzer", {
			settings = {
				["rust-analyzer"] = {
					-- run clippy instead of plain `cargo check` on save, so
					-- clippy lints show up as real-time diagnostics
					check = { command = "clippy" },
					inlayHints = {
						typeHints = { enable = true },
						bindingModeHints = { enable = true },
						closureReturnTypeHints = { enable = "always" },
						lifetimeElisionHints = { enable = "skip_trivial" },
						parameterHints = { enable = true },
					},
				},
			},
		})

		local ok, mason_registry = pcall(require, "mason-registry")
		if ok then
			local ok2, pkg = pcall(mason_registry.get_package, "powershell-editor-services")
			if ok2 and pkg:is_installed() then
				vim.lsp.config("powershell_es", {
					bundle_path = pkg:get_install_path(),
				})
			end
		end

		require("mason-lspconfig").setup({
			ensure_installed = {
				"rust_analyzer",
				"vtsls",
				"eslint",
				"powershell_es",
			},
		})

		-- Enable inlay type hints (inferred variable types, parameter names, etc.)
		-- for any LSP client that supports them, on attach.
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client:supports_method("textDocument/inlayHint") then
					vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
				end
			end,
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
			virtual_text = {
				spacing = 4,
				prefix = "●",
				source = false, -- keep the inline text short; source shows in the float instead
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.INFO] = "",
					[vim.diagnostic.severity.HINT] = "",
				},
			},
			underline = true,
			severity_sort = true,
			-- Neovim's default (false) only redraws diagnostics on leaving insert
			-- mode, which reads as "only updates when I :w" since Esc always
			-- precedes :w anyway. RustRover-style continuous feedback needs this on.
			update_in_insert = true,
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
