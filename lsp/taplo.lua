-- lsp/taplo.lua
return {
  filetypes    = { "toml" },
  root_markers = { "pyproject.toml", "Cargo.toml", ".git" },
  settings = {
    taplo = {
      schema = { enabled = true },
      formatter = {
        alignEntries       = false,
        alignComments      = true,
        arrayTrailingComma = true,
        compactArrays      = false,
        indentTables       = false,
        indentEntries      = false,
        inlineTableExpand  = false,
        columnWidth        = 80,
        indentString       = "  ",
        reorderKeys        = false,
        allowedBlankLines  = 1,
        trailingNewline    = true,
      },
    },
  },
}
