vim.api.nvim_create_autocmd("FileType", {
  pattern = "unison",
  callback = function(args)
    -- Proviamo ad avviare treesitter direttamente sul buffer.
    -- Se fallisce (es. parser non installato), pcall evita l'errore rosso.
    pcall(function()
      vim.treesitter.start(args.buf, "unison")
      vim.lsp.enable("unison")
    end)
  end,
})
