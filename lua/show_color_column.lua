--  draw a vertical line to visualize textwidth
vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufRead" },
  {
    pattern = { "*.py", "*.sh", "*.bash" },
    callback = function()
      vim.opt_local.colorcolumn = { 80 }
      vim.opt_local.textwidth = 80
    end
  })

