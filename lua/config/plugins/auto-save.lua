return {
	"okuuva/auto-save.nvim",
	event = { "InsertLeave", "TextChanged" },
	opts = {
		enabled = true,
		-- noautocmd: skip BufWritePre/BufWritePost etc for these background
		-- saves, so conform's format-on-save doesn't fire on every debounced
		-- autosave while typing. Manual :w / <leader>f still format normally.
		noautocmd = true,
		trigger_events = {
			immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
			defer_save = { "InsertLeave", "TextChanged" },
			cancel_deferred_save = { "InsertEnter" },
		},
		debounce_delay = 1000,
	},
}
