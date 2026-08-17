return {
	"99",
	dir = "~/personal/99",
	config = function()
		local _99 = require("99")
		_99.setup({
			provider = _99.Providers.ClaudeCodeProvider,
			model = "claude-sonnet-4-5",
		})

		vim.keymap.set("n", "<leader>9s", function()
			_99.search()
		end)
		-- _99.visual() with no args already opens an interactive prompt for what
		-- to do with the selection; there's no separate visual_prompt() function
		-- in this plugin (verified against source), so a second "9vp" binding
		-- would just call a nil function and error.
		vim.keymap.set("v", "<leader>9vv", function()
			_99.visual()
		end)
		vim.keymap.set("n", "<leader>9x", function()
			_99.stop_all_requests()
		end)
		vim.keymap.set("n", "<leader>9m", function()
			require("99.extensions.telescope").select_model()
		end)
		-- Capital P: lowercase <leader>9p is left free in this build, but capital
		-- keeps the provider picker visually grouped with the model picker and
		-- avoids ever colliding with a future prev/next-style <leader>9p binding.
		vim.keymap.set("n", "<leader>9P", function()
			require("99.extensions.telescope").select_provider()
		end)
	end,
}
