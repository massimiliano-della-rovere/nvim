local function create_highlight_git_blame_inline()
  local highlight_comment = vim.api.nvim_get_hl(0, { name = "Comment" })
  local highlight_git_blame = vim.tbl_deep_extend("keep", highlight_comment, {})
  if vim.o.cursorline == true then
    local highlight_cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    local cursorline_bg = highlight_cursorline.bg
    if cursorline_bg then
      highlight_git_blame.bg = cursorline_bg
    end
  end
  vim.api.nvim_set_hl(0, "GitBlameInline", highlight_git_blame)
end

local highlight_group = vim.api.nvim_create_augroup(
  "GitBlameInlineHighlight",
  { clear = true })

local events = {
  ColorScheme = "*",
  OptionSet = "cursorline",
  BufEnter = "*",
  BufNew = "*",
}

for event_name, pattern in pairs(events) do
  vim.api.nvim_create_autocmd(
    event_name,
    {
      callback = create_highlight_git_blame_inline,
      group = highlight_group,
      pattern = pattern,
    })
end
