return {

  -- DB UI
  {
    -- https://github.com/kristijanhusak/vim-dadbod-ui
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {

      -- DB engine
      {
        -- https://github.com/tpope/vim-dadbod
        "tpope/vim-dadbod",
        lazy = true,
        config = function()
          -- vim.g.db_ui_save_location = vim.fn.stdpath("config" .. require("plenary.path").path.sep .. "db_ui")
        end,
      },

      -- Autocompletion / cmp plugin using DB stuff as source
      {
        -- https://github.com/kristijanhusak/vim-dadbod-completion
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql" },
        lazy = true,
        config = function()
        end,
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
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      -- vim.g.db_ui_disable_mappings = 1

      local autocomplete_group = vim.api.nvim_create_augroup(
        "vimrc_autocompletion",
        { clear = true })

      vim.api.nvim_create_autocmd(
        "FileType",
        {
          pattern = { "sql" },
          group = autocomplete_group,
          command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
        })

      -- local function db_completion()
      --   require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
      -- end

      vim.api.nvim_create_autocmd(
        "FileType",
        {
          pattern = { "sql", "mysql", "plsql" },
          group = autocomplete_group,
          callback = function()
            -- vim.schedule(db_completion)
            require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
          end,
        })

      local key_prefix = "<leader>b"
      for _, cfg in ({
        { key = "a", command = "DBUIAddConnection", desc = "DB: Add connection" },
        { key = "f", command = "DBUIFindBuffer", desc = "DB: Find Buffer" },
        { key = "q", command = "DBUILastQueryInfo", desc = "DB: Last Query info" },
        { key = "r", command = "DBUIRenameBuffer", desc = "DB: Rename Buffer" },
        { key = "u", command = "DBUIToggle", desc = "DB: Toggle UI" },
      }) do
        vim.api.nvim_set_keymap(
          "n", key_prefix .. cfg.key,
          "<CMD>" .. cfg.command .. "<CR>",
          { noremap = true, desc = cfg.desc })
      end
    end,
  },

  -- SSH tunnel for dadbod/DB connections
  {
    -- https://github.com/pbogut/vim-dadbod-ssh
    "pbogut/vim-dadbod-ssh",
  },

}
