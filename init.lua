-- install lazy
local function download_lazy(lazy_path)
  -- Lazy plugin manager
  -- https://github.com/folke/lazy.nvim
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    -- "--branch=stable", -- latest stable release
    lazy_path,
  })
end


local function include_lazy()
  local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  local stat, error = vim.loop.fs_stat(lazy_path)
  if stat == nil or error ~= 0 then
    download_lazy(lazy_path)
  end
  vim.opt.rtp:prepend(lazy_path)
end


include_lazy()
require("set_leaders")
require("lazy").setup({
  change_detection = { enabled = true },
  checker = { enabled = true, notify = false },
  -- rocks = { hererocks = true, },  -- recommended if you do not have global installation of Lua 5.1.
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
