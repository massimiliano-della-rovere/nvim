-- set tab handling
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Set search path
vim.opt.path:append("**")

-- Preview changes in smaller window
-- vim.opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor.
-- vim.opt.scrolloff = 999

-- Virtual edit in visual "block" mode
vim.opt.virtualedit = "block"

-- Crosshair on current character
vim.opt.cursorcolumn = true
vim.opt.cursorline = true

-- Set highlight on search
vim.opt.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- keep signcolumn always of to avoid screen jumping
vim.opt.signcolumn = "yes"

-- Enable mouse mode
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamed,unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true
-- Enable persistent undo so that undo history persists across vim sessions

---@diagnostic disable-next-line: param-type-mismatch
vim.opt.undodir = vim.fn.expand(vim.fn.stdpath("state")) .. "/undo"
if vim.fn.isdirectory(vim.o.undodir) == 0 then
  vim.fn.mkdir(vim.o.undodir, "p")
end

-- search wraps at top from bottom
vim.opt.wrapscan = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Set completeopt to have a better completion experience
-- vim.opt.completeopt = "menuone,noselect,noinsert"

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

-- set border to floating windows
local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = _border })

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = _border })

vim.diagnostic.config{float = { border = _border }}

-- new split windows
vim.opt.splitbelow = true
vim.opt.splitright = true

-- c-a and c-x target
vim.opt.nrformats = { "bin", "octal", "hex" }

-- char symbols
vim.opt.listchars = {
  eol = "¶",
  tab = "‹·›",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "•",
  conceal = "×"}
vim.opt.showbreak = "⮎" -- ⤷ +++

-- folding
-- vim.opt.foldmethod = "syntax"
-- vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldminlines = 5
vim.opt.foldnestmax = 10
-- if not vim.startswith(vim.g.colors_name, "kanagawa") then
--  vim.api.nvim_set_hl(0, "Folded", { bg = "#403000", fg = "#FF40FF" })
-- end

-- spell language
vim.opt.encoding = "utf-8"
-- make sure the spellfile directory exists, sometimes nvim fails to create it 
-- when downloading spellfiles
-- if NetRW is disabled, downloading of spellfiles fails!
-- See the comment in the filesystem_browsing.lua file in the Oil plugin section.
vim.fn.mkdir(vim.fn.stdpath("data") .. "site/spell", "p")
vim.opt.spell = false
vim.opt.spelllang = { "en_us", "it", "eo" }
