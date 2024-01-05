return {
  -- DB
  {
    "kristijanhusak/vim-dadbod-ui",
    build = ":TSInstall sqlls",  -- :TSInstall sqlls
    dependencies = {
      {
        "tpope/vim-dadbod",
        lazy = true,
        config = function()
          -- vim.g.db_ui_save_location = vim.fn.stdpath("config" .. require("plenary.path").path.sep .. "db_ui")
        end
      },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql" },
        lazy = true,
        config = function()
          vim.api.nvim_create_autocmd(
            "FileType",
            { pattern = { "sql", },
              command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
            })

          local function db_completion()
            require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
          end

          local autocomplete_group = vim.api.nvim_create_augroup("vimrc_autocompletion", { clear = true })
          vim.api.nvim_create_autocmd(
            "FileType",
            {
              pattern = { "sql", "mysql", "plsql" },
              group = autocomplete_group,
              callback = function()
                -- vim.schedule(db_completion)
                require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
              end,
            }
          )
        end
      },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    build = ":TSInstall sql",
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Da",
        ":DBUIAddConnection<CR>",
        { noremap = true, desc = "[D]B [A]dd connection" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Du",
        ":DBUIToggle<CR>",
        { noremap = true, desc = "[D]B toggle [U]I" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Df",
        ":DBUIFindBuffer<CR>",
        { noremap = true, desc = "[D]B [F]ind buffer" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Dr",
        ":DBUIRenameBuffer<CR>",
        { noremap = true, desc = "[D]B [R]ename buffer" })

      vim.api.nvim_set_keymap(
        "n",
        "<leader>Dq",
        ":DBUILastQueryInfo<CR>",
        { noremap = true, desc = "[D]B last [Q]uery info" })
    end,
  },
}
