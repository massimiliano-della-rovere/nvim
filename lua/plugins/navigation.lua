return {
  -- ctags generation
  {
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_project_root = {
        ".git",
        "package.json",
        "LICENSE",
        "README.md"
      }
      vim.g.gutentags_ctags_tagfile = "tags"
      vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/vim/ctags/")
      vim.api.nvim_create_user_command(
        "GutentagsClearCache",
        vim.fn.system("rm " .. vim.g.gutentags_cache_dir .. "/*"),
        { desc = "Clear Gutentags cache in " .. vim.g.gutentags_cache_dir }
      )
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0
      vim.g.gutentags_ctags_extra_args = { "--tag-relative=yes", "--fields=+ailmnS" }
      vim.g.gutentags_ctags_exclude = FILE_EXTENSIONS_EXCLUDED_FROM_CTAGS_GENERATION
    end
  },

  -- File Browser
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      local fb_actions = require "telescope._extensions.file_browser.actions"

      require("telescope").load_extension("file_browser")

      vim.api.nvim_set_keymap(
        "n",
        "<space>fb",
        ":Telescope file_browser<CR>",
        { noremap = true, desc = "[F]ile [B]rowser" })
    end
  },

   -- filesystem as a buffer
  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup()
      vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open parent directory" })
    end
  }, 
}
