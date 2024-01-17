return {

  -- wrap file oriented utilities (linters, formatters, ...) into a generic LSP
  {
    -- https://github.com/nvimtools/none-ls.nvim
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
          null_ls.builtins.code_actions.eslint_d, -- Javascript / Typescript

          null_ls.builtins.diagnostics.eslint_d, -- Javascript / Typescript
          null_ls.builtins.diagnostics.shellcheck, -- BASh

          null_ls.builtins.formatting.black, -- Python
          null_ls.builtins.formatting.prettier, -- Javascript / Typescript
          null_ls.builtins.formatting.isort, -- Python
          null_ls.builtins.formatting.stylua, -- LUA
          null_ls.builtins.formatting.yamlfmt, -- YAML
        }
      })
    end,
  },

}
