return {

  -- marks in the left column
  {
    -- https://github.com/chentoast/marks.nvim
    "chentoast/marks.nvim",
    config = function()
      require("marks").setup()
    end
  },

  -- discoverable key sequences
  {
    -- https://github.com/folke/which-key.nvim
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      require("which-key").register({
        ["<leader>"] = { name = "VISUAL <leader>", _ = "which_key_ignore" },
        ["<leader>b"] = { name = "+db", _ = "which_key_ignore"  },
        ["<leader>c"] = { name = "+colorscheme", _ = "which_key_ignore" },
        ["<leader>cc"] = { name = "+colorscheme/catpuccin", _ = "which_key_ignore" },
        ["<leader>cg"] = { name = "+colorscheme/gruvbox", _ = "which_key_ignore" },
        ["<leader>ck"] = { name = "+colorscheme/kanagawa", _ = "which_key_ignore" },
        ["<leader>ct"] = { name = "+colorscheme/tokyonight", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "+debug", _ = "which_key_ignore" },
        ["<leader>f"] = { name = "+find", _ = "which_key_ignore" },
        ["<leader>g"] = { name = "+git/telescope", _ = "which_key_ignore" },
        ["<leader>h"] = { name = "+git/fugitive", _ = "which_key_ignore" },
        ["<leader>k"] = { name = "+docker", _ = "which_key_ignore" },
        ["<leader>l"] = { name = "+lsp/code", _ = "which_key_ignore" },
        ["<leader>o"] = { name = "+oil", _ = "which_key_ignore" },
        ["<leader>n"] = { name = "+notes", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "+rename", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "+spectre", _ = "which_key_ignore" },
        ["<leader>S"] = { name = "+surround", _ = "which_key_ignore" },
        ["<leader>t"] = { name = "+treesj", _ = "which_key_ignore" },
        ["<leader>v"] = { name = "+view", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "+workspace", _ = "which_key_ignore" },
        ["<leader>x"] = { name = "+trouble", _ = "which_key_ignore" },
      })
    end,
  },

  -- Window resize
  {
    -- https://github.com/anuvyklack/windows.nvim
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim"
    },
    config = function()
      vim.opt.winwidth = 10
      vim.opt.winminwidth = 10
      vim.opt.equalalways = false

      require("windows").setup()

      vim.keymap.set("n", "<C-w>z", ":WindowsMaximize<CR>")
      vim.keymap.set("n", "<C-w>_", ":WindowsMaximizeVertically<CR>")
      vim.keymap.set("n", "<C-w>|", ":WindowsMaximizeHorizontally<CR>")
      vim.keymap.set("n", "<C-w>=", ":WindowsEqualize<CR>")
    end
  },

  -- replaces the UI for messages, cmdline and the popupmenu_show
  {
    -- https://github.com/folke/noice.nvim
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      })

      require("telescope").load_extension("noice")
    end
  },


}
