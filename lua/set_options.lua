-- [[ Setting options ]]
-- See `:help vim.o`

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set search path
vim.opt.path:append("**")

-- Preview changes in smaller window
vim.opt.inccommand = "split"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 999

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

-- Enable mouse mode
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

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
vim.opt.completeopt = 'menuone,noselect,noinsert'

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

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
-- vim.opt.foldmethod = 'syntax'
-- vim.opt.foldenable = true
vim.opt.foldlevel = 0
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldminlines = 5
vim.opt.foldnestmax = 10
if not vim.startswith(vim.g.colors_name, "kanagawa") then
  vim.api.nvim_set_hl(0, "Folded", { bg = "#403000", fg = "#FF40FF" })
end

-- spell languages
vim.opt.spell = false
vim.opt.spelllang = { "en_us", "it", "eo" }

