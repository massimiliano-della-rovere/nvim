-- lsp/vimls.lua
return {
  filetypes    = { "vim" },
  root_markers = { ".git" },
  init_options = {
    isNeovim    = true,
    iskeyword   = "@,48-57,_,192-255,-#",
    vimruntime  = vim.env.VIMRUNTIME,
    runtimepath = vim.o.runtimepath,
    diagnostic  = { enable = true },
    indexes = {
      runtimepath         = true,
      gap                 = 100,
      count               = 3,
      projectRootPatterns = { ".git", "autoload", "plugin" },
    },
    suggest = { fromVimruntime = true, fromRuntimepath = true },
  },
}
