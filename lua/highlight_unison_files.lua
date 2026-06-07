-- ============================================================
-- highlight_unison_files.lua  –  Neovim 0.12
-- ============================================================
-- NOTA 0.12: vim.treesitter.get_parser() non lancia più eccezione
-- in caso di fallimento: restituisce nil. La pcall rimane utile
-- per catturare altri errori runtime.

vim.api.nvim_create_autocmd("FileType", {
  pattern  = "unison",
  callback = function(args)
    -- get_parser ora ritorna nil (non lancia) se il parser non esiste
    local parser = vim.treesitter.get_parser(args.buf, "unison")
    if parser then
      vim.treesitter.start(args.buf, "unison")
    end
    -- l'enable dell'LSP è gestito in lsp/unison.lua
    -- qui lo richiamiamo solo come fallback per il filetype autocmd
    pcall(vim.lsp.enable, "unison")
  end,
})
