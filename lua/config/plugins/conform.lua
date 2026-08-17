return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			format_on_save = {
				timeout_ms = 5000,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				rust = { "rustfmt" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				dart = { "dart_format" },
				ps1 = { "psscriptanalyzer_format" },
			},
			formatters = {
				-- powershell_es doesn't advertise documentFormattingProvider, so LSP
				-- fallback formatting is a no-op for PowerShell. Format directly via
				-- PSScriptAnalyzer's Invoke-Formatter instead.
				psscriptanalyzer_format = {
					command = "powershell",
					args = {
						"-NoProfile",
						"-NonInteractive",
						"-Command",
						-- Invoke-Formatter throws on mixed line endings (common after a
						-- git checkout on Windows), so normalize to LF before formatting.
						-- Also force the CurrentUser Windows PowerShell module path: when
						-- nvim is launched from pwsh (PowerShell 7), a spawned `powershell`
						-- (5.1) child inherits pwsh's PSModulePath, which doesn't include
						-- 5.1's own module dir where PSScriptAnalyzer is installed, so
						-- `Import-Module PSScriptAnalyzer` silently fails to find it
						-- without this.
						"$env:PSModulePath = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\\Modules') + ';' + $env:PSModulePath; $s = ([Console]::In.ReadToEnd()) -replace \"`r`n\", \"`n\" -replace \"`r\", \"`n\"; Import-Module PSScriptAnalyzer; Invoke-Formatter -ScriptDefinition $s | Write-Output -NoEnumerate",
					},
					stdin = true,
				},
			},
		})

		vim.keymap.set("n", "<leader>f", function()
			require("conform").format({ bufnr = 0 })
		end)
	end,
}
