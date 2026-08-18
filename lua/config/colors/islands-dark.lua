-- Ported 1:1 from the user's own RustRover 2026.2 "Islands Dark" scheme
-- (Settings > Editor > Color Scheme > Export > .icls), not approximated.
--
-- "Islands" itself is JetBrains' UI-chrome redesign (rounded corners, panel
-- spacing/separation) introduced in 2025 - it isn't a distinct syntax
-- palette. The actual editor colors underneath are this Darcula-derived
-- scheme (parent_scheme="Darcula" in the exported file); that's what's
-- ported here.
local M = {}

M.palette = {
	bg = "#191a1c", -- TEXT.BACKGROUND / CONSOLE_BACKGROUND_KEY
	bg_cursorline = "#1f2024", -- CARET_ROW_COLOR
	bg_popup = "#27282b", -- LOOKUP_COLOR (autocomplete popup)
	bg_highlight = "#2b2d30", -- DIFF_SEPARATORS_BACKGROUND / breadcrumbs bg
	bg_selection = "#43454a", -- MATCHED_BRACE_ATTRIBUTES.BACKGROUND
	bg_search = "#114957", -- TEXT_SEARCH_RESULT_ATTRIBUTES.BACKGROUND
	border = "#393b40", -- HINT_BORDER

	fg = "#bcbec4", -- TEXT.FOREGROUND / DEFAULT_IDENTIFIER
	fg_bright = "#ced0d6", -- CARET_COLOR / ANNOTATIONS_LAST_COMMIT_COLOR
	fg_dim = "#8d9199", -- ANNOTATIONS_COLOR
	comment = "#7a7e85", -- DEFAULT_LINE_COMMENT / DEFAULT_BLOCK_COMMENT
	doc_comment = "#5f826b", -- DEFAULT_DOC_COMMENT
	line_nr = "#4b5059", -- LINE_NUMBERS_COLOR
	line_nr_active = "#a1a3ab", -- LINE_NUMBER_ON_CARET_ROW_COLOR

	keyword = "#cf8e6d", -- DEFAULT_KEYWORD (fn, let, match, ...)
	string = "#6aab73", -- DEFAULT_STRING
	number = "#2aacb8", -- DEFAULT_NUMBER
	func = "#56a8f5", -- DEFAULT_FUNCTION_DECLARATION / org.rust.FUNCTION_CALL
	constant = "#c77dbb", -- DEFAULT_CONSTANT / DEFAULT_INSTANCE_FIELD
	metadata = "#b3ae60", -- DEFAULT_METADATA (#[derive(...)] etc.)
	tag = "#d5b778", -- XML_TAG_NAME / HTML_TAG_NAME

	red = "#f75464", -- CONSOLE_ERROR_OUTPUT / WRONG_REFERENCES_ATTRIBUTES
	yellow = "#f2c55c", -- WARNING_ATTRIBUTES.EFFECT_COLOR
	blue = "#56a8f5",
	green = "#73bd79", -- FILESTATUS_ADDED
	purple = "#b189f5", -- FOLLOWED_HYPERLINK_ATTRIBUTES

	diff_add = "#549159", -- ADDED_LINES_COLOR
	diff_change = "#375fad", -- MODIFIED_LINES_COLOR
	diff_delete = "#868a91", -- DELETED_LINES_COLOR
}

function M.setup()
	vim.cmd("hi clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.background = "dark"
	vim.o.termguicolors = true
	vim.g.colors_name = "islands-dark"

	local p = M.palette
	local function hl(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- Editor chrome
	hl("Normal", { fg = p.fg, bg = p.bg })
	hl("NormalFloat", { fg = p.fg, bg = p.bg_popup })
	hl("FloatBorder", { fg = p.border, bg = p.bg_popup })
	hl("CursorLine", { bg = p.bg_cursorline })
	hl("CursorLineNr", { fg = p.line_nr_active, bold = true })
	hl("LineNr", { fg = p.line_nr })
	hl("SignColumn", { bg = p.bg })
	hl("ColorColumn", { bg = p.bg_cursorline })
	hl("Visual", { bg = p.bg_selection })
	hl("VisualNOS", { bg = p.bg_selection })
	hl("Search", { bg = p.bg_search })
	hl("IncSearch", { fg = p.bg, bg = p.yellow })
	hl("CurSearch", { fg = p.bg, bg = p.yellow })
	hl("Pmenu", { fg = p.fg, bg = p.bg_popup })
	hl("PmenuSel", { fg = p.fg_bright, bg = p.bg_selection })
	hl("PmenuSbar", { bg = p.bg_popup })
	hl("PmenuThumb", { bg = p.border })
	hl("StatusLine", { fg = p.fg, bg = p.bg_highlight })
	hl("StatusLineNC", { fg = p.fg_dim, bg = p.bg_highlight })
	hl("WinSeparator", { fg = p.border, bg = p.bg })
	hl("VertSplit", { fg = p.border, bg = p.bg })
	hl("TabLine", { fg = p.fg_dim, bg = p.bg_highlight })
	hl("TabLineSel", { fg = p.fg_bright, bg = p.bg_selection })
	hl("TabLineFill", { bg = p.bg })
	hl("NonText", { fg = p.line_nr })
	hl("EndOfBuffer", { fg = p.bg })
	hl("Whitespace", { fg = p.line_nr })
	hl("MatchParen", { bg = p.bg_selection, bold = true })
	hl("Title", { fg = p.blue, bold = true })
	hl("Directory", { fg = p.blue })
	hl("ErrorMsg", { fg = p.red })
	hl("WarningMsg", { fg = p.yellow })
	hl("Question", { fg = p.blue })
	hl("MoreMsg", { fg = p.green })
	hl("ModeMsg", { fg = p.fg })

	-- Legacy syntax groups (Treesitter captures below link back to some of these
	-- by default in Neovim's own runtime, so both are set explicitly)
	hl("Comment", { fg = p.comment, italic = true })
	hl("Constant", { fg = p.constant })
	hl("String", { fg = p.string })
	hl("Character", { fg = p.string })
	hl("Number", { fg = p.number })
	hl("Boolean", { fg = p.keyword })
	hl("Float", { fg = p.number })
	hl("Identifier", { fg = p.fg })
	hl("Function", { fg = p.func })
	hl("Statement", { fg = p.keyword })
	hl("Conditional", { fg = p.keyword })
	hl("Repeat", { fg = p.keyword })
	hl("Label", { fg = p.keyword })
	hl("Operator", { fg = p.fg })
	hl("Keyword", { fg = p.keyword })
	hl("Exception", { fg = p.keyword })
	hl("PreProc", { fg = p.metadata })
	hl("Include", { fg = p.keyword })
	hl("Define", { fg = p.keyword })
	hl("Macro", { fg = p.func })
	hl("PreCondit", { fg = p.metadata })
	hl("Type", { fg = p.fg })
	hl("StorageClass", { fg = p.keyword })
	hl("Structure", { fg = p.fg })
	hl("Typedef", { fg = p.fg })
	hl("Special", { fg = p.keyword })
	hl("SpecialChar", { fg = p.keyword })
	hl("Tag", { fg = p.tag })
	hl("Delimiter", { fg = p.fg })
	hl("SpecialComment", { fg = p.doc_comment })
	hl("Debug", { fg = p.red })
	hl("Underlined", { underline = true })
	hl("Ignore", { fg = p.line_nr })
	hl("Error", { fg = p.red })
	hl("Todo", { fg = "#8bb33d", bold = true }) -- TODO_DEFAULT_ATTRIBUTES

	-- Treesitter captures
	hl("@variable", { fg = p.fg })
	hl("@variable.builtin", { fg = p.constant })
	hl("@variable.parameter", { fg = p.fg })
	hl("@property", { fg = p.constant }) -- DEFAULT_INSTANCE_FIELD
	hl("@field", { fg = p.constant })
	hl("@constant", { fg = p.constant })
	hl("@constant.builtin", { fg = p.constant })
	hl("@string", { fg = p.string })
	hl("@string.escape", { fg = p.keyword }) -- DEFAULT_VALID_STRING_ESCAPE
	hl("@number", { fg = p.number })
	hl("@boolean", { fg = p.keyword }) -- true/false are keywords in Rust
	hl("@function", { fg = p.func })
	hl("@function.call", { fg = p.func })
	hl("@function.builtin", { fg = p.func })
	hl("@method", { fg = p.func })
	hl("@method.call", { fg = p.func })
	hl("@constructor", { fg = p.fg })
	hl("@keyword", { fg = p.keyword })
	hl("@keyword.function", { fg = p.keyword })
	hl("@keyword.return", { fg = p.keyword })
	hl("@keyword.operator", { fg = p.keyword })
	hl("@conditional", { fg = p.keyword })
	hl("@repeat", { fg = p.keyword })
	hl("@operator", { fg = p.fg })
	hl("@punctuation.bracket", { fg = p.fg })
	hl("@punctuation.delimiter", { fg = p.fg })
	hl("@punctuation.special", { fg = p.fg })
	-- Types render in plain foreground, matching real RustRover: this scheme
	-- has no dedicated type/class color (DEFAULT_CLASS_REFERENCE = fg too),
	-- only keywords/strings/numbers/comments/functions/constants stand out.
	hl("@type", { fg = p.fg })
	hl("@type.builtin", { fg = p.fg })
	hl("@attribute", { fg = p.metadata }) -- #[derive(...)], DEFAULT_METADATA
	hl("@namespace", { fg = p.fg })
	hl("@comment", { fg = p.comment, italic = true })
	hl("@tag", { fg = p.tag })
	hl("@tag.attribute", { fg = p.fg_dim })
	hl("@tag.delimiter", { fg = p.fg_dim })

	-- Diagnostics
	hl("DiagnosticError", { fg = p.red })
	hl("DiagnosticWarn", { fg = p.yellow })
	hl("DiagnosticInfo", { fg = p.blue })
	hl("DiagnosticHint", { fg = p.fg_dim })
	hl("DiagnosticOk", { fg = p.green })
	for _, sev in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
		hl("DiagnosticVirtualText" .. sev, { link = "Diagnostic" .. sev })
		hl("DiagnosticSign" .. sev, { link = "Diagnostic" .. sev })
	end
	hl("DiagnosticUnderlineError", { undercurl = true, sp = p.red })
	hl("DiagnosticUnderlineWarn", { undercurl = true, sp = p.yellow })
	hl("DiagnosticUnderlineInfo", { undercurl = true, sp = p.blue })
	hl("DiagnosticUnderlineHint", { undercurl = true, sp = p.fg_dim })

	-- Diff
	hl("DiffAdd", { fg = p.diff_add })
	hl("DiffChange", { fg = p.diff_change })
	hl("DiffDelete", { fg = p.diff_delete })
	hl("DiffText", { fg = p.fg, bg = p.bg_selection })
end

return M
