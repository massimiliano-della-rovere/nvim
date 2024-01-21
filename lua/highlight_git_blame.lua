function CreateHighlightGitBlameInline(event)
  local highlight_comment = vim.api.nvim_get_hl(0, { name = "Comment" })
  local highlight_git_blame = vim.tbl_deep_extend("keep", highlight_comment, {})
  -- vim.print({ event = event, cursorline = vim.o.cursorline })
  if vim.o.cursorline == true then
    local highlight_cursorline = vim.api.nvim_get_hl(0, { name = "Cursorline" })
    local cursorline_bg = highlight_cursorline.bg
    if cursorline_bg then
      highlight_git_blame.bg = cursorline_bg
    end
  end
  vim.api.nvim_set_hl(0, "GitBlameInline", highlight_git_blame)
end

local highlight_group = vim.api.nvim_create_augroup("GitBlameInlineHighlight", { clear = true })

for event_name, pattern in pairs({
  ColorScheme = "*",
  OptionSet = "cursorline",
  -- VimEnter = "*",
})
do
  vim.api.nvim_create_autocmd(
    event_name,
    {
      callback = CreateHighlightGitBlameInline,
      group = highlight_group,
      pattern = pattern,
    })
end
