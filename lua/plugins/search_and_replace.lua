return {
  -- search and replace using popup window
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { is_block_ui_break = true },
  },

  -- improved search, add, delete, swap using regex
  "tpope/vim-abolish",

  -- Fuzzy Finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    priority = 80, -- make sure it starts before the telescope file browser
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",
      "sharkdp/fd",
      "nvim-treesitter/nvim-treesitter",
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
    },
    config = function()
      local fb_actions = require("telescope._extensions.file_browser.actions")
      require("telescope").setup({
        extensions = {
          file_browser = {
            path = vim.loop.cwd(),
            cwd = vim.loop.cwd(),
            cwd_to_path = false,
            grouped = false,
            files = true,
            add_dirs = true,
            depth = 1,
            auto_depth = false,
            select_buffer = false,
            hidden = { file_browser = false, folder_browser = false },
            respect_gitignore = vim.fn.executable "fd" == 1,
            no_ignore = false,
            follow_symlinks = false,
            browse_files = require("telescope._extensions.file_browser.finders").browse_files,
            browse_folders = require("telescope._extensions.file_browser.finders").browse_folders,
            hide_parent_dir = false,
            collapse_dirs = false,
            prompt_path = false,
            quiet = false,
            dir_icon = "",
            dir_icon_hl = "Default",
            display_stat = { date = true, size = true, mode = true },
            hijack_netrw = false,
            use_fd = true,
            git_status = true,
            mappings = {
              ["i"] = {
                ["<C-u>"] = false,
                ["<C-d>"] = false,
                ["<A-c>"] = fb_actions.create,
                ["<S-CR>"] = fb_actions.create_from_prompt,
                ["<A-r>"] = fb_actions.rename,
                ["<A-m>"] = fb_actions.move,
                ["<A-y>"] = fb_actions.copy,
                ["<A-d>"] = fb_actions.remove,
                ["<C-o>"] = fb_actions.open,
                ["<C-g>"] = fb_actions.goto_parent_dir,
                ["<C-e>"] = fb_actions.goto_home_dir,
                ["<C-w>"] = fb_actions.goto_cwd,
                ["<C-t>"] = fb_actions.change_cwd,
                ["<C-f>"] = fb_actions.toggle_browser,
                ["<C-h>"] = fb_actions.toggle_hidden,
                ["<C-s>"] = fb_actions.toggle_all,
                ["<bs>"] = fb_actions.backspace,
              },
              ["n"] = {
                ["c"] = fb_actions.create,
                ["r"] = fb_actions.rename,
                ["m"] = fb_actions.move,
                ["y"] = fb_actions.copy,
                ["d"] = fb_actions.remove,
                ["o"] = fb_actions.open,
                ["g"] = fb_actions.goto_parent_dir,
                ["e"] = fb_actions.goto_home_dir,
                ["w"] = fb_actions.goto_cwd,
                ["t"] = fb_actions.change_cwd,
                ["f"] = fb_actions.toggle_browser,
                ["h"] = fb_actions.toggle_hidden,
                ["s"] = fb_actions.toggle_all,
              },
            },
          },
        },
      })

      -- Enable telescope fzf native, if installed
      pcall(require("telescope").load_extension, "fzf")

      -- Telescope live_grep in git root
      -- Function to find the git root directory based on the current buffer"s path
      local function find_git_root()
        -- Use the current buffer"s path as the starting point for the git search
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()
        -- If the buffer is not associated with a file, return nil
        if current_file == "" then
          current_dir = cwd
        else
          -- Extract the directory from the current file"s path
          current_dir = vim.fn.fnamemodify(current_file, ":h")
        end

        -- Find the Git root directory from the current file"s path
        local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 then
          print("Not a git repository. Searching on current working directory")
          return cwd
        end
        return git_root
      end

      -- Custom live_grep function to search in git root
      local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
          require("telescope.builtin").live_grep({
            search_dirs = {git_root},
          })
        end
      end

      vim.api.nvim_create_user_command(
        "LiveGrepGitRoot",
        live_grep_git_root,
        {})

      -- See `:help telescope.builtin`
      vim.keymap.set(
        "n", "<leader>?",
        require("telescope.builtin").oldfiles,
        { desc = "[?] Find recently opened files" })
      vim.keymap.set(
        "n", "<leader><space>",
        require("telescope.builtin").buffers,
        { desc = "[ ] Find existing buffers" })
      vim.keymap.set(
        "n", "<leader>/",
        function()
          -- You can pass additional configuration to telescope to change theme, layout, etc.
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = "[/] Fuzzily search in current buffer" })

      local function telescope_live_grep_open_files()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end
      vim.keymap.set(
        "n", "<leader>s/",
        telescope_live_grep_open_files,
        { desc = "[S]earch [/] in Open Files" })
      vim.keymap.set(
        "n", "<leader>ss",
        ":SymbolsOutline<cr>",
        { desc = "[S]earch [S]ymbols outline" })
      vim.keymap.set(
        "n", "<leader>gf",
        require("telescope.builtin").git_files,
        { desc = "Search [G]it [F]iles" })
      vim.keymap.set(
        "n", "<leader>sf",
        require("telescope.builtin").find_files,
        { desc = "[S]earch [F]iles" })
      vim.keymap.set(
        "n", "<leader>sh",
        require("telescope.builtin").help_tags,
        { desc = "[S]earch [H]elp" })
      vim.keymap.set(
        "n", "<leader>sw",
        require("telescope.builtin").grep_string,
        { desc = "[S]earch current [W]ord" })
      vim.keymap.set(
        "n", "<leader>sg",
        require("telescope.builtin").live_grep,
        { desc = "[S]earch by [G]rep" })
      vim.keymap.set(
        "n", "<leader>sG",
        ":LiveGrepGitRoot<cr>",
        { desc = "[S]earch by [G]rep on Git Root" })
      vim.keymap.set(
        "n", "<leader>sd",
        require("telescope.builtin").diagnostics,
        { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set(
        "n", "<leader>sr",
        require("telescope.builtin").resume,
        { desc = "[S]earch [R]esume" })
    end
  },
}
