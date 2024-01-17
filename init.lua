-- install lazy
function download_lazy(lazypath)
  -- Lazy plugin manager
  -- https://github.com/folke/lazy.nvim
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  download_lazy(lazypath)
end
vim.opt.rtp:prepend(lazypath)



require("set_leaders")
require("lazy").setup("plugins")
require("highlight_on_yank")
require("set_options")
require("set_keymaps")
require("show_color_column")
