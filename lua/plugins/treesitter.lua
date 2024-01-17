return {

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- the following parsers are required by the noice plugin:
          -- vim, regex, lua, bash, markdown and markdown_inline
          "bash", "c", "css", "javascript", "lua", "markdown", "markdown_inline",
          "python", "query", "regex", "sql", "vim", "vimdoc"
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

}
