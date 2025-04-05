return {

  -- fuzzy find
  {
    -- https://github.com/nvim-telescope/telescope.nvim
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nosduco/remote-sshfs.nvim",
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",
      "sharkdp/fd",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      },
      "nvim-telescope/telescope-live-grep-args.nvim", -- options when serching files
      "nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
      "xiyaowong/telescope-emoji.nvim", -- find specific emoji
      "ghassan0/telescope-glyph.nvim", -- glyph search in a font
      "nvim-telescope/telescope-ui-select.nvim", -- set `vim.ui.select` to telescope
      "lpoto/telescope-docker.nvim", -- docker control panel
      "debugloop/telescope-undo.nvim", -- undo tree
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      local lga_actions = require("telescope-live-grep-args.actions")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<M-d>"] = actions.delete_buffer,
            },
            n = {
              ["<M-d>"] = actions.delete_buffer,
            },
          },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = { -- extend mappings
              i = {
                -- ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                -- freeze the current list and start a fuzzy search in the frozen list
                ["<C-space>"] = lga_actions.to_fuzzy_refine,
              },
            },
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
          },
          ["ui-select"] = { require("telescope.themes").get_dropdown({}) }
        },
      })
      for _, extension in pairs({ "docker", "emoji", "fzf", "glyph", "live_grep_args", "remote-sshfs", "ui-select", "undo" }) do
        telescope.load_extension(extension)
      end

      local builtin = require("telescope.builtin")
      local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
      local sshfs_connections = require("remote-sshfs.connections")
      local sshfs_api = require("remote-sshfs.api")

      vim.keymap.set(
        "n", "<leader>Rc",
        sshfs_api.connect,
        { desc = "Remote/sshfs connect" })
      vim.keymap.set(
        "n", "<leader>Rd",
        sshfs_api.disconnect,
        { desc = "Remote/sshfs disconnect" })
      vim.keymap.set(
        "n", "<leader>Re",
        sshfs_api.edit,
        { desc = "Remote/sshfs edit" })

      -- (optional) Override telescope find_files and live_grep to make dynamic based on if connected to host
      vim.keymap.set(
        "n", "<leader>ff",
        function()
          if sshfs_connections.is_connected() then
            sshfs_api.find_files()
          else
            builtin.find_files()
          end
        end,
        { desc = "Files w/o hidden in CWD" })
      vim.keymap.set(
        "n", "<leader>fh",
        function()
          if sshfs_connections.is_connected() then
            sshfs_api.find_files({ hidden = true })
          else
            builtin.find_files({ hidden = true })
          end
        end,
        { desc = "Files w/ hidden in CWD" })
      vim.keymap.set(
        "n", "<leader>fg",
        function()
          if sshfs_connections.is_connected() then
            sshfs_api.live_grep()
          else
            -- builtin.live_grep()
            telescope.extensions.live_grep_args.live_grep_args()
          end
        end,
        { desc = "Grep in CWD" })

      -- file pickers
      vim.keymap.set(
        "n", "<leader>fv",
        live_grep_args_shortcuts.grep_visual_selection,
        { desc = "grep with visual selection" })
      vim.keymap.set(
        "n", "<leader>fc",
        live_grep_args_shortcuts.grep_word_under_cursor,
        { desc = "grep word under cursor" })
      vim.keymap.set(
        "n", "<leader>ff",
        builtin.find_files,
        { desc = "Files in CWD" })
      -- vim.keymap.set(
      --   "n", "<leader>fh",
      --   function() builtin.find_files({ hidden = true }) end,
      --   { desc = "Files w/ hidden in CWD" })
      -- vim.keymap.set(
      --   "n", "<leader>fg",
      --   telescope.extensions.live_grep_args.live_grep_args,
      --   -- builtin.live_grep,
      --   { desc = "Grep in CWD" })
      -- vim.keymap.set(
      --   "n", "<leader>fG",
      --   builtin.git_files,
      --   { desc = "Grep in Git files" })
      vim.keymap.set(
        "n", "<leader>fs",
        builtin.grep_string,
        { desc = "Under cursor in CWD" })
      -- vim pickers
      vim.keymap.set(
        "n", "<leader>va",
        builtin.autocommands,
        { desc = "View Autocommands" })
      vim.keymap.set(
        "n", "<leader>vb",
        builtin.buffers,
        { desc = "View Buffers" })
      vim.keymap.set(
        "n", "<leader>vB",
        builtin.builtin,
        { desc = "View Builtins" })
      vim.keymap.set(
        "n", "<leader>vc",
        builtin.commands,
        { desc = "View Commands" })
      vim.keymap.set(
        "n", "<leader>ve",
        telescope.extensions.emoji.emoji,
        { desc = "View Emoji" })
      vim.keymap.set(
        "n", "<leader>vf",
        builtin.filetypes,
        { desc = "View Filetypes" })
      vim.keymap.set(
        "n", "<leader>vg",
        telescope.extensions.glyph.glyph,
        { desc = "View Glyph" })
      vim.keymap.set(
        "n", "<leader>vh",
        builtin.highlights,
        { desc = "View Highlights" })
      vim.keymap.set(
        "n", "<leader>vi",
        builtin.lsp_incoming_calls,
        { desc = "View Incoming Calls" })
      vim.keymap.set(
        "n", "<leader>vj",
        builtin.jumplist,
        { desc = "View Jumps" })
      vim.keymap.set(
        "n", "<leader>vk",
        builtin.keymaps,
        { desc = "View Keymaps" })
      vim.keymap.set(
        "n", "<leader>vl",
        builtin.loclist,
        { desc = "View Location List" })
      vim.keymap.set(
        "n", "<leader>vm",
        builtin.marks,
        { desc = "View Marks" })
      vim.keymap.set(
        "n", "<leader>vo",
        builtin.lsp_outgoing_calls,
        { desc = "View Outgoing Calls" })
      vim.keymap.set(
        "n", "<leader>vO",
        builtin.vim_options,
        { desc = "View Vim Options" })
      vim.keymap.set(
        "n", "<leader>vp",
        builtin.man_pages,
        { desc = "View Man Pages" })
      vim.keymap.set(
        "n", "<leader>vq",
        builtin.quickfix,
        { desc = "View Quickfix List" })
      vim.keymap.set(
        "n", '<leader>v"',
        builtin.registers,
        { desc = "View Registers" })
      vim.keymap.set(
        "n", "<leader>vr",
        builtin.reloader,
        { desc = "View Lua Modules" })
      vim.keymap.set(
        "n", "<leader>vs",
        builtin.symbols,
        { desc = "View Symbols" })
      vim.keymap.set(
        "n", "<leader>vt",
        builtin.tags,
        { desc = "View Tags" })
      vim.keymap.set(
        "n", "<leader>vu",
        telescope.extensions.undo.undo,
        { desc = "View Undo tree" })
      vim.keymap.set(
        "n", "<leader>vT",
        builtin.current_buffer_tags,
        { desc = "View Tags in Buffer" })
      vim.keymap.set(
        "n", "<leader>vz",
        builtin.spell_suggest,
        { desc = "View Spelling Suggestions" })
      vim.keymap.set(
        "n", "<leader>v!",
        builtin.treesitter,
        { desc = "View Treesitter symbols" })
      vim.keymap.set(
        "n", "<leader>v/",
        builtin.search_history,
        { desc = "View Search History" })
      vim.keymap.set(
        "n", "<leader>v&",
        builtin.command_history,
        { desc = "View Command History" })
      vim.keymap.set(
        "n", "<leader>v?",
        builtin.help_tags,
        { desc = "View HelpTags" })
      vim.keymap.set(
        "n", "<leader>v~",
        builtin.colorscheme,
        { desc = "View Colorschemes" })
      -- lsp pickers
      vim.keymap.set(
        "n", "<leader>vd",
        builtin.diagnostics,
        { desc = "View Buffer Diagnostics" })
      -- git pickers
      vim.keymap.set(
        "n", "<leader>gb",
        builtin.git_branches,
        { desc = "Git Branches" })
      vim.keymap.set(
        "n", "<leader>gB",
        builtin.git_bcommits,
        { desc = "Git Blame" })
      vim.keymap.set(
        "n", "<leader>gc",
        builtin.git_commits,
        { desc = "Git Commits" })
      -- vim.keymap.set(
      --   "n", "<leader>gr",
      --   builtin.git_bcommits_range,
      --   { desc = "Git Commits Range" })
      vim.keymap.set(
        "n", "<leader>gs",
        builtin.git_status,
        { desc = "Git Status" })
      vim.keymap.set(
        "n", "<leader>gS",
        builtin.git_stash,
        { desc = "Git Stash" })
      -- extensions and integrations
      vim.keymap.set(
        "n", "<leader>vn",
        "<CMD>TodoTelescope<CR>",
        { desc = 'View "Notes" tags' })

      -- Docker
      local docker_prefix = "<leader>k"
      for key, command in pairs({
        c = "containers",
        d = "docker",
        f = "files",
        i = "images",
        m = "machines",
        n = "networks",
        o = "contexts",
        s = "swarm",
        v = "volumes",
      }) do
        vim.keymap.set(
          "n", docker_prefix .. key,
          telescope.extensions.docker[command],
          { desc = "Docker: " .. (command:lower():gsub("^%l", string.upper)) })
      end
    end
  },

}
