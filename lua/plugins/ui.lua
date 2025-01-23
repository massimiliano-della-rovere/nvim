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
      require("which-key").add({
        { "<leader>", group = "VISUAL <leader>" },
        { "<leader>S", group = "surround" },
        { "<leader>S_", hidden = true },
        { "<leader>_", hidden = true },
        { "<leader>b", group = "db" },
        { "<leader>b_", hidden = true },
        { "<leader>c", group = "colorscheme" },
        { "<leader>c_", hidden = true },
        { "<leader>cc", group = "colorscheme/catpuccin" },
        { "<leader>cc_", hidden = true },
        { "<leader>cg", group = "colorscheme/gruvbox" },
        { "<leader>cg_", hidden = true },
        { "<leader>ck", group = "colorscheme/kanagawa" },
        { "<leader>ck_", hidden = true },
        { "<leader>ct", group = "colorscheme/tokyonight" },
        { "<leader>ct_", hidden = true },
        { "<leader>d", group = "debug" },
        { "<leader>d_", hidden = true },
        { "<leader>f", group = "find" },
        { "<leader>f_", hidden = true },
        { "<leader>g", group = "git/telescope" },
        { "<leader>g_", hidden = true },
        { "<leader>h", group = "git/fugitive" },
        { "<leader>h_", hidden = true },
        { "<leader>k", group = "docker" },
        { "<leader>k_", hidden = true },
        { "<leader>l", group = "lsp/code" },
        { "<leader>l_", hidden = true },
        { "<leader>n", group = "notes" },
        { "<leader>n_", hidden = true },
        { "<leader>o", group = "oil" },
        { "<leader>o_", hidden = true },
        { "<leader>r", group = "rename" },
        { "<leader>r_", hidden = true },
        { "<leader>R", group = "Remote/sshfs" },
        { "<leader>R_", hidden = true },
        { "<leader>s", group = "spectre" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "treesj" },
        { "<leader>t_", hidden = true },
        { "<leader>v", group = "view" },
        { "<leader>v_", hidden = true },
        { "<leader>w", group = "workspace" },
        { "<leader>w_", hidden = true },
        { "<leader>x", group = "trouble" },
        { "<leader>x_", hidden = true },



        -- ["<leader>"] = { name = "VISUAL <leader>", _ = "which_key_ignore" },
        -- ["<leader>b"] = { name = "+db", _ = "which_key_ignore"  },
        -- ["<leader>c"] = { name = "+colorscheme", _ = "which_key_ignore" },
        -- ["<leader>cc"] = { name = "+colorscheme/catpuccin", _ = "which_key_ignore" },
        -- ["<leader>cg"] = { name = "+colorscheme/gruvbox", _ = "which_key_ignore" },
        -- ["<leader>ck"] = { name = "+colorscheme/kanagawa", _ = "which_key_ignore" },
        -- ["<leader>ct"] = { name = "+colorscheme/tokyonight", _ = "which_key_ignore" },
        -- ["<leader>d"] = { name = "+debug", _ = "which_key_ignore" },
        -- ["<leader>f"] = { name = "+find", _ = "which_key_ignore" },
        -- ["<leader>g"] = { name = "+git/telescope", _ = "which_key_ignore" },
        -- ["<leader>h"] = { name = "+git/fugitive", _ = "which_key_ignore" },
        -- ["<leader>k"] = { name = "+docker", _ = "which_key_ignore" },
        -- ["<leader>l"] = { name = "+lsp/code", _ = "which_key_ignore" },
        -- ["<leader>o"] = { name = "+oil", _ = "which_key_ignore" },
        -- ["<leader>n"] = { name = "+notes", _ = "which_key_ignore" },
        -- ["<leader>r"] = { name = "+rename", _ = "which_key_ignore" },
        -- ["<leader>s"] = { name = "+spectre", _ = "which_key_ignore" },
        -- ["<leader>S"] = { name = "+surround", _ = "which_key_ignore" },
        -- ["<leader>t"] = { name = "+treesj", _ = "which_key_ignore" },
        -- ["<leader>v"] = { name = "+view", _ = "which_key_ignore" },
        -- ["<leader>w"] = { name = "+workspace", _ = "which_key_ignore" },
        -- ["<leader>x"] = { name = "+trouble", _ = "which_key_ignore" },
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
