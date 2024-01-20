-- install lazy
local function download_lazy(lazy_path)
  -- Lazy plugin manager
  -- https://github.com/folke/lazy.nvim
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazy_path,
  })
end


local function include_lazy()
  local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazy_path) then
    download_lazy(lazy_path)
  end
  vim.opt.rtp:prepend(lazy_path)
end


include_lazy()
require("set_leaders")
require("lazy").setup({
  change_detection = { enabled = true },
  checker = { enabled = true, notify = false },
  spec = {
    { "LazyVim/LazyVim", import = "plugins" },
    { import = "plugins" },
  },
  ui = { border = "single", custom_keys = {} },
})
require("highlight_on_yank")
require("set_options")
require("set_keymaps")
require("show_color_column")
