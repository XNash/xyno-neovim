return {
	"okuuva/auto-save.nvim",
	event = { "InsertLeave", "TextChanged" },
	config = function()
		-- noautocmd (below) skips BufWritePre/BufWritePost for autosaves so
		-- conform's format-on-save doesn't fire on every debounced autosave -
		-- but that also silently skips the LSP client's BufWritePost-triggered
		-- `textDocument/didSave`, which rust-analyzer's on-save diagnostic
		-- refresh (check.command = "clippy") relies on. Confirmed directly:
		-- `noautocmd write` sends zero LSP notifications, a normal `write`
		-- sends textDocument/didSave. Without this, diagnostics only ever
		-- refresh on a manual :w.
		--
		-- auto-save.nvim has no save-lifecycle hooks to hang this off of, so
		-- wrap vim.cmd narrowly: only for the exact command string it builds
		-- internally, send didSave ourselves right after the real (synchronous)
		-- write completes - correctly ordered, no debounce-timing races.
		local real_cmd = vim.cmd
		---@diagnostic disable-next-line: duplicate-set-field
		vim.cmd = function(command)
			local is_autosave_write = type(command) == "string" and command:match("^noautocmd .*silent! w")
			local result = real_cmd(command)
			if is_autosave_write then
				for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
					if client:supports_method("textDocument/didSave") then
						client:notify("textDocument/didSave", {
							textDocument = { uri = vim.uri_from_bufnr(0) },
						})
					end
				end
			end
			return result
		end

		require("auto-save").setup({
			enabled = true,
			noautocmd = true,
			trigger_events = {
				immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
				defer_save = { "InsertLeave", "TextChanged" },
				cancel_deferred_save = { "InsertEnter" },
			},
			debounce_delay = 1000,
		})
	end,
}
