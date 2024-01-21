--  draw a vertical line to visualize textwidth
local show_color_column_group = vim.api.nvim_create_augroup("ShowColorColumn", { clear = true })
vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufRead" },
  {
    group = show_color_column_group,
    pattern = { "*.py", "*.sh", "*.bash" },
    callback = function()
      vim.opt_local.colorcolumn = { 80 }
      vim.opt_local.textwidth = 80
    end
  })

