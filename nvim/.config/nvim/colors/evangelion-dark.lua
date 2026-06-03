-- Evangelion Dark colorscheme for Neovim.
-- Ported from the iTerm2 "Evangelion Dark" preset to match the terminal + Zed
-- editor palette. Dark plum background, lavender accents, Eva-01 neon green.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "evangelion-dark"

local c = {
  bg         = "#0d0d18",
  bg_dark    = "#0a0a14",
  bg_alt     = "#12121f",
  bg_hl      = "#16162a",
  selection  = "#2a2a40",
  border     = "#2a2a40",
  fg         = "#e2e2f0",
  fg_dim     = "#9a9ab0",
  fg_mute    = "#5a5a80",
  line_nr    = "#3a3a55",
  comment    = "#5a5a80",
  cursor     = "#a78bfa",
  red        = "#ef4444",
  red_br     = "#f87171",
  orange     = "#fbbf24",
  yellow     = "#fcd34d",
  green      = "#39ff14",
  green_soft = "#7aff5e",
  cyan       = "#22d3ee",
  cyan_br    = "#67e8f9",
  blue       = "#8b5cf6",
  purple     = "#a78bfa",
  magenta    = "#c084fc",
  pink       = "#d8b4fe",
  white      = "#f5f5ff",
  none       = "NONE",
  diff_add   = "#14241a",
  diff_chg   = "#1f1d28",
  diff_del   = "#2a1414",
  diff_txt   = "#1d3322",
}

local set = vim.api.nvim_set_hl

local function hl(group, spec)
  set(0, group, spec)
end

-- UI / editor chrome ---------------------------------------------------------
hl("Normal",       { fg = c.fg,    bg = c.bg })
hl("NormalNC",     { fg = c.fg,    bg = c.bg })
hl("NormalFloat",  { fg = c.fg,    bg = c.bg_alt })
hl("FloatBorder",  { fg = c.border, bg = c.bg_alt })
hl("FloatTitle",   { fg = c.purple, bg = c.bg_alt, bold = true })
hl("WinSeparator", { fg = c.border, bg = c.none })
hl("VertSplit",    { fg = c.border, bg = c.none })
hl("ColorColumn",  { bg = c.bg_hl })
hl("Conceal",      { fg = c.fg_mute })
hl("CurSearch",    { fg = c.bg, bg = c.orange, bold = true })
hl("Cursor",       { fg = c.bg, bg = c.cursor })
hl("CursorLine",   { bg = c.bg_hl })
hl("CursorColumn", { bg = c.bg_hl })
hl("CursorLineNr", { fg = c.purple, bold = true })
hl("LineNr",       { fg = c.line_nr })
hl("SignColumn",   { fg = c.fg_dim, bg = c.none })
hl("FoldColumn",   { fg = c.fg_mute, bg = c.none })
hl("Folded",       { fg = c.fg_dim, bg = c.bg_alt })
hl("EndOfBuffer",  { fg = c.bg })
hl("MatchParen",   { fg = c.orange, bold = true, underline = true })
hl("ModeMsg",      { fg = c.fg, bold = true })
hl("MoreMsg",      { fg = c.green_soft })
hl("MsgArea",      { fg = c.fg })
hl("NonText",      { fg = c.fg_mute })
hl("Whitespace",   { fg = c.line_nr })
hl("SpecialKey",   { fg = c.fg_mute })
hl("Question",     { fg = c.purple })
hl("Search",       { fg = c.bg, bg = c.purple, bold = true })
hl("IncSearch",    { fg = c.bg, bg = c.orange, bold = true })
hl("Substitute",   { fg = c.bg, bg = c.orange })
hl("Visual",       { bg = c.selection })
hl("VisualNOS",    { bg = c.selection })
hl("Title",        { fg = c.purple, bold = true })
hl("Directory",    { fg = c.cyan_br })
hl("ErrorMsg",     { fg = c.red, bold = true })
hl("WarningMsg",   { fg = c.orange, bold = true })

hl("StatusLine",   { fg = c.fg, bg = c.bg_alt })
hl("StatusLineNC", { fg = c.fg_mute, bg = c.bg_dark })

hl("TabLine",      { fg = c.fg_dim, bg = c.bg_dark })
hl("TabLineFill",  { bg = c.bg_dark })
hl("TabLineSel",   { fg = c.purple, bg = c.selection, bold = true })

hl("Pmenu",        { fg = c.fg, bg = c.bg_alt })
hl("PmenuSel",     { fg = c.purple, bg = c.selection, bold = true })
hl("PmenuSbar",    { bg = c.bg_alt })
hl("PmenuThumb",   { bg = c.selection })
hl("WildMenu",     { fg = c.bg, bg = c.purple })
hl("QuickFixLine", { bg = c.bg_hl, bold = true })

hl("SpellBad",     { sp = c.red,    undercurl = true })
hl("SpellCap",     { sp = c.orange, undercurl = true })
hl("SpellLocal",   { sp = c.cyan,   undercurl = true })
hl("SpellRare",    { sp = c.magenta, undercurl = true })

-- Standard syntax groups -----------------------------------------------------
hl("Comment",      { fg = c.comment, italic = true })
hl("Constant",     { fg = c.orange })
hl("String",       { fg = c.green_soft })
hl("Character",    { fg = c.green_soft })
hl("Number",       { fg = c.orange })
hl("Float",        { fg = c.orange })
hl("Boolean",      { fg = c.orange, bold = true })

hl("Identifier",   { fg = c.fg })
hl("Function",     { fg = c.cyan_br })

hl("Statement",    { fg = c.magenta })
hl("Conditional",  { fg = c.magenta, italic = true })
hl("Repeat",       { fg = c.magenta, italic = true })
hl("Label",        { fg = c.magenta })
hl("Operator",     { fg = c.purple })
hl("Keyword",      { fg = c.magenta, italic = true })
hl("Exception",    { fg = c.red })

hl("PreProc",      { fg = c.pink })
hl("Include",      { fg = c.pink })
hl("Define",       { fg = c.pink })
hl("Macro",        { fg = c.pink })
hl("PreCondit",    { fg = c.pink })

hl("Type",         { fg = c.yellow })
hl("StorageClass", { fg = c.yellow, italic = true })
hl("Structure",    { fg = c.yellow })
hl("Typedef",      { fg = c.yellow })

hl("Special",      { fg = c.green })
hl("SpecialChar",  { fg = c.green })
hl("Tag",          { fg = c.red })
hl("Delimiter",    { fg = c.fg_dim })
hl("SpecialComment", { fg = c.purple, italic = true })
hl("Debug",        { fg = c.red })

hl("Underlined",   { underline = true })
hl("Ignore",       { fg = c.fg_mute })
hl("Error",        { fg = c.red, bold = true })
hl("Todo",         { fg = c.bg, bg = c.orange, bold = true })

-- Treesitter -----------------------------------------------------------------
hl("@comment",                  { link = "Comment" })
hl("@comment.todo",             { fg = c.bg, bg = c.orange, bold = true })
hl("@comment.note",             { fg = c.bg, bg = c.cyan_br, bold = true })
hl("@comment.warning",          { fg = c.bg, bg = c.orange, bold = true })
hl("@comment.error",            { fg = c.white, bg = c.red, bold = true })

hl("@variable",                 { fg = c.fg })
hl("@variable.builtin",         { fg = c.red, italic = true })
hl("@variable.parameter",       { fg = c.pink })
hl("@variable.member",          { fg = c.cyan_br })

hl("@constant",                 { fg = c.orange })
hl("@constant.builtin",         { fg = c.orange, bold = true })
hl("@constant.macro",           { fg = c.pink })

hl("@module",                   { fg = c.yellow })
hl("@module.builtin",           { fg = c.yellow, italic = true })
hl("@label",                    { fg = c.magenta })

hl("@string",                   { fg = c.green_soft })
hl("@string.documentation",     { fg = c.fg_dim, italic = true })
hl("@string.regexp",            { fg = c.green })
hl("@string.escape",            { fg = c.green, bold = true })
hl("@string.special",           { fg = c.green })
hl("@string.special.url",       { fg = c.cyan_br, underline = true })

hl("@character",                { fg = c.green_soft })
hl("@character.special",        { fg = c.green })

hl("@boolean",                  { fg = c.orange, bold = true })
hl("@number",                   { fg = c.orange })
hl("@number.float",             { fg = c.orange })

hl("@type",                     { fg = c.yellow })
hl("@type.builtin",             { fg = c.yellow, italic = true })
hl("@type.definition",          { fg = c.yellow })
hl("@type.qualifier",           { fg = c.magenta, italic = true })

hl("@attribute",                { fg = c.pink })
hl("@property",                 { fg = c.cyan_br })

hl("@function",                 { fg = c.cyan_br })
hl("@function.builtin",         { fg = c.cyan_br, italic = true })
hl("@function.call",            { fg = c.cyan_br })
hl("@function.macro",           { fg = c.pink })
hl("@function.method",          { fg = c.cyan_br })
hl("@function.method.call",     { fg = c.cyan_br })

hl("@constructor",              { fg = c.yellow })
hl("@operator",                 { fg = c.purple })

hl("@keyword",                  { fg = c.magenta, italic = true })
hl("@keyword.coroutine",        { fg = c.magenta, italic = true })
hl("@keyword.function",         { fg = c.magenta, italic = true })
hl("@keyword.operator",         { fg = c.purple })
hl("@keyword.import",           { fg = c.pink })
hl("@keyword.type",             { fg = c.yellow, italic = true })
hl("@keyword.modifier",         { fg = c.magenta, italic = true })
hl("@keyword.repeat",           { fg = c.magenta, italic = true })
hl("@keyword.return",           { fg = c.magenta, italic = true, bold = true })
hl("@keyword.debug",            { fg = c.red })
hl("@keyword.exception",        { fg = c.red, italic = true })
hl("@keyword.conditional",      { fg = c.magenta, italic = true })
hl("@keyword.directive",        { fg = c.pink })

hl("@punctuation.delimiter",    { fg = c.fg_dim })
hl("@punctuation.bracket",      { fg = c.fg_dim })
hl("@punctuation.special",      { fg = c.purple })

hl("@tag",                      { fg = c.red })
hl("@tag.attribute",            { fg = c.orange, italic = true })
hl("@tag.delimiter",            { fg = c.fg_mute })

hl("@markup.heading",           { fg = c.purple, bold = true })
hl("@markup.heading.1",         { fg = c.purple, bold = true })
hl("@markup.heading.2",         { fg = c.magenta, bold = true })
hl("@markup.heading.3",         { fg = c.cyan_br, bold = true })
hl("@markup.heading.4",         { fg = c.yellow, bold = true })
hl("@markup.heading.5",         { fg = c.green_soft, bold = true })
hl("@markup.heading.6",         { fg = c.pink, bold = true })
hl("@markup.strong",            { bold = true, fg = c.orange })
hl("@markup.italic",            { italic = true, fg = c.magenta })
hl("@markup.strikethrough",     { strikethrough = true })
hl("@markup.underline",         { underline = true })
hl("@markup.quote",             { fg = c.fg_dim, italic = true })
hl("@markup.math",              { fg = c.cyan_br })
hl("@markup.link",              { fg = c.cyan_br, underline = true })
hl("@markup.link.label",        { fg = c.purple })
hl("@markup.link.url",          { fg = c.cyan_br, underline = true })
hl("@markup.raw",               { fg = c.green_soft })
hl("@markup.list",              { fg = c.purple })
hl("@markup.list.checked",      { fg = c.green })
hl("@markup.list.unchecked",    { fg = c.fg_mute })

hl("@diff.plus",                { fg = c.green_soft, bg = c.diff_add })
hl("@diff.minus",               { fg = c.red,        bg = c.diff_del })
hl("@diff.delta",               { fg = c.orange,     bg = c.diff_chg })

-- LSP ------------------------------------------------------------------------
hl("@lsp.type.namespace",       { link = "@module" })
hl("@lsp.type.type",            { link = "@type" })
hl("@lsp.type.class",           { link = "@type" })
hl("@lsp.type.enum",            { link = "@type" })
hl("@lsp.type.interface",       { link = "@type" })
hl("@lsp.type.struct",          { link = "@type" })
hl("@lsp.type.parameter",       { link = "@variable.parameter" })
hl("@lsp.type.variable",        { link = "@variable" })
hl("@lsp.type.property",        { link = "@property" })
hl("@lsp.type.enumMember",      { link = "@constant" })
hl("@lsp.type.function",        { link = "@function" })
hl("@lsp.type.method",          { link = "@function.method" })
hl("@lsp.type.macro",           { link = "@function.macro" })
hl("@lsp.type.decorator",       { link = "@attribute" })

hl("DiagnosticError",           { fg = c.red })
hl("DiagnosticWarn",            { fg = c.orange })
hl("DiagnosticInfo",            { fg = c.cyan_br })
hl("DiagnosticHint",            { fg = c.purple })
hl("DiagnosticOk",              { fg = c.green_soft })
hl("DiagnosticUnderlineError",  { sp = c.red,    undercurl = true })
hl("DiagnosticUnderlineWarn",   { sp = c.orange, undercurl = true })
hl("DiagnosticUnderlineInfo",   { sp = c.cyan_br, undercurl = true })
hl("DiagnosticUnderlineHint",   { sp = c.purple, undercurl = true })
hl("DiagnosticVirtualTextError",{ fg = c.red,    bg = c.none, italic = true })
hl("DiagnosticVirtualTextWarn", { fg = c.orange, bg = c.none, italic = true })
hl("DiagnosticVirtualTextInfo", { fg = c.cyan_br, bg = c.none, italic = true })
hl("DiagnosticVirtualTextHint", { fg = c.purple, bg = c.none, italic = true })

hl("LspReferenceText",          { bg = c.selection })
hl("LspReferenceRead",          { bg = c.selection })
hl("LspReferenceWrite",         { bg = c.selection, bold = true })
hl("LspInlayHint",              { fg = c.fg_mute, bg = c.bg_alt, italic = true })
hl("LspSignatureActiveParameter", { fg = c.purple, bold = true })

-- Diff -----------------------------------------------------------------------
hl("DiffAdd",     { bg = c.diff_add })
hl("DiffChange",  { bg = c.diff_chg })
hl("DiffDelete",  { fg = c.red, bg = c.diff_del })
hl("DiffText",    { bg = c.diff_txt, bold = true })

hl("Added",       { fg = c.green_soft })
hl("Changed",     { fg = c.orange })
hl("Removed",     { fg = c.red })

-- Git plugins ----------------------------------------------------------------
hl("GitSignsAdd",          { fg = c.green_soft })
hl("GitSignsChange",       { fg = c.orange })
hl("GitSignsDelete",       { fg = c.red })
hl("GitSignsAddNr",        { fg = c.green_soft })
hl("GitSignsChangeNr",     { fg = c.orange })
hl("GitSignsDeleteNr",     { fg = c.red })
hl("GitSignsCurrentLineBlame", { fg = c.fg_mute, italic = true })

-- Telescope ------------------------------------------------------------------
hl("TelescopeNormal",         { fg = c.fg,     bg = c.bg_alt })
hl("TelescopeBorder",         { fg = c.border, bg = c.bg_alt })
hl("TelescopePromptNormal",   { fg = c.fg,     bg = c.bg_hl })
hl("TelescopePromptBorder",   { fg = c.bg_hl,  bg = c.bg_hl })
hl("TelescopePromptTitle",    { fg = c.bg,     bg = c.purple, bold = true })
hl("TelescopePreviewTitle",   { fg = c.bg,     bg = c.cyan_br, bold = true })
hl("TelescopeResultsTitle",   { fg = c.bg,     bg = c.green_soft, bold = true })
hl("TelescopeSelection",      { fg = c.purple, bg = c.selection, bold = true })
hl("TelescopeMatching",       { fg = c.orange, bold = true })

-- which-key ------------------------------------------------------------------
hl("WhichKey",          { fg = c.purple })
hl("WhichKeyGroup",     { fg = c.cyan_br })
hl("WhichKeyDesc",      { fg = c.fg })
hl("WhichKeySeparator", { fg = c.fg_mute })
hl("WhichKeyFloat",     { bg = c.bg_alt })
hl("WhichKeyBorder",    { fg = c.border, bg = c.bg_alt })

-- neo-tree / nvim-tree -------------------------------------------------------
hl("NeoTreeNormal",          { fg = c.fg,    bg = c.bg_dark })
hl("NeoTreeNormalNC",        { fg = c.fg,    bg = c.bg_dark })
hl("NeoTreeRootName",        { fg = c.purple, bold = true })
hl("NeoTreeDirectoryName",   { fg = c.fg })
hl("NeoTreeDirectoryIcon",   { fg = c.purple })
hl("NeoTreeIndentMarker",    { fg = c.line_nr })
hl("NeoTreeGitAdded",        { fg = c.green_soft })
hl("NeoTreeGitModified",     { fg = c.orange })
hl("NeoTreeGitDeleted",      { fg = c.red })
hl("NeoTreeGitUntracked",    { fg = c.pink })
hl("NeoTreeGitIgnored",      { fg = c.fg_mute })
hl("NeoTreeWinSeparator",    { fg = c.bg_dark, bg = c.bg_dark })
hl("NeoTreeCursorLine",      { bg = c.selection })

-- bufferline -----------------------------------------------------------------
hl("BufferLineFill",            { bg = c.bg_dark })
hl("BufferLineBackground",      { fg = c.fg_dim, bg = c.bg_dark })
hl("BufferLineBufferSelected",  { fg = c.purple, bg = c.bg, bold = true })
hl("BufferLineBufferVisible",   { fg = c.fg,     bg = c.bg_alt })
hl("BufferLineIndicatorSelected", { fg = c.purple, bg = c.bg })

-- noice / notify -------------------------------------------------------------
hl("NoiceCmdlinePopupBorder",   { fg = c.purple })
hl("NoiceCmdlinePopupTitle",    { fg = c.purple, bold = true })
hl("NoiceCmdlineIcon",          { fg = c.purple })
hl("NotifyERRORBorder", { fg = c.red })
hl("NotifyWARNBorder",  { fg = c.orange })
hl("NotifyINFOBorder",  { fg = c.cyan_br })
hl("NotifyDEBUGBorder", { fg = c.fg_dim })
hl("NotifyTRACEBorder", { fg = c.magenta })
hl("NotifyERRORIcon",   { fg = c.red })
hl("NotifyWARNIcon",    { fg = c.orange })
hl("NotifyINFOIcon",    { fg = c.cyan_br })
hl("NotifyDEBUGIcon",   { fg = c.fg_dim })
hl("NotifyTRACEIcon",   { fg = c.magenta })
hl("NotifyERRORTitle",  { fg = c.red,    bold = true })
hl("NotifyWARNTitle",   { fg = c.orange, bold = true })
hl("NotifyINFOTitle",   { fg = c.cyan_br, bold = true })

-- indent-blankline -----------------------------------------------------------
hl("IblIndent",    { fg = c.line_nr })
hl("IblScope",     { fg = c.purple })
hl("IblWhitespace", { fg = c.line_nr })

-- mini.* ---------------------------------------------------------------------
hl("MiniIndentscopeSymbol", { fg = c.purple })
hl("MiniStatuslineFilename", { fg = c.fg, bg = c.bg_alt })

-- Built-in :terminal palette -------------------------------------------------
vim.g.terminal_color_0  = "#12121f"
vim.g.terminal_color_1  = "#ef4444"
vim.g.terminal_color_2  = "#39ff14"
vim.g.terminal_color_3  = "#fbbf24"
vim.g.terminal_color_4  = "#8b5cf6"
vim.g.terminal_color_5  = "#c084fc"
vim.g.terminal_color_6  = "#22d3ee"
vim.g.terminal_color_7  = "#e2e2f0"
vim.g.terminal_color_8  = "#2a2a40"
vim.g.terminal_color_9  = "#f87171"
vim.g.terminal_color_10 = "#7aff5e"
vim.g.terminal_color_11 = "#fcd34d"
vim.g.terminal_color_12 = "#a78bfa"
vim.g.terminal_color_13 = "#d8b4fe"
vim.g.terminal_color_14 = "#67e8f9"
vim.g.terminal_color_15 = "#f5f5ff"
