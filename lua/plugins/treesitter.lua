return {

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local parser_config = require("nvim-treesitter.parsers")
      parser_config.unison = {
        install_info = {
          -- url = "https://github.com/kallmanation/tree-sitter-unison",
          url = "https://github.com/kylegoetz/tree-sitter-unison",
          files = {"src/parser.c", "src/scanner.c"},
          branch = "main",
        },
      }

      require("nvim-treesitter.config").setup({
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",    -- Invio per iniziare a selezionare la parola sotto il cursore
            node_incremental = "<CR>",  -- Invio ancora per espandere al blocco logico superiore (es. tutto il Thunk)
            scope_incremental = "<TAB>", -- Tab per selezionare lo scope (es. tutta la funzione)
            node_decremental = "<BS>",  -- Backspace per tornare indietro
          },
        },
        ensure_installed = {
          -- the following parsers are required by the noice plugin:
          -- vim, regex, lua, bash, markdown and markdown_inline
          "bash", "c", "css", "javascript", "lua", "markdown", "markdown_inline",
          "python", "query", "regex", "sql", "unison", "vim", "vimdoc"
        },
        auto_install = true,
        -- highlight = { enable = true },
        highlight = {
          enable = true, -- DEVE essere true

          -- Opzionale: disabilita se il file è troppo grande
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,

          -- IMPORTANTE: Impostalo a false. 
          -- Se è true, rallenta tutto e può causare conflitti con la vecchia sintassi regex che vedevi prima.
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
    lazy = false
  },

}
