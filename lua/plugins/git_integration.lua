return {

  -- git integration
  -- https://github.com/tpope/vim-fugitive
  "tpope/vim-fugitive",

  -- git :GBrowse
  -- https://github.com/tpope/vim-rhubarb
  "tpope/vim-rhubarb",

  -- git operation symbols on the symbol bar
  -- https://github.com/airblade/vim-gitgutter
  -- "airblade/vim-gitgutter",

  -- blame shown at the end of the line
  -- https://github.com/f-person/git-blame.nvim
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    config = function()
      -- change the language of date_format
      -- require("lua-timeago").set_language(require("lua-timeago/languages/en"))

      require("gitblame").setup({
        enabled = true,
        date_format = "%Y-%m-%d %a %H:%M:%S",
        message_template = "  <author> • <date> • <summary> • <sha>",
        message_when_not_committed = "  Not Committed Yet",
        highlight_group = "GitBlameInline",
        set_extmark_options = {},
        display_virtual_text = true,
        ignored_filetypes = {},
        delay = 0,
        virtual_text_column = nil,
        -- open GitBlameOpenFileURL and GitBlameCopyFileURL at the latest blame commit
        -- (in other words, the commit marked by the blame)
        use_blame_commit_file_urls = true,
      })
    end,
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
  -- https://github.com/lewis6991/gitsigns.nvim
    "lewis6991/gitsigns.nvim",
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add          = { text = "+" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        vim.keymap.set(
          { "n", "v" }, "]c",
          function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(gs.next_hunk)
            return "<Ignore>"
          end,
          { expr = true, buffer = bufnr, desc = "Git: To next Change" })
        vim.keymap.set(
          { "n", "v" }, "[c",
          function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(gs.prev_hunk)
            return "<Ignore>"
          end,
          { expr = true, buffer = bufnr, desc = "Git: To prev Change" })

        -- Actions
        -- visual mode
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line ".", vim.fn.line "v" })
        end, { desc = "GIT: Stage hunk" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line ".", vim.fn.line "v" })
        end, { desc = "GIT: Reset hunk" })
        -- normal mode
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Git: stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "Git: reset hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Git: Stage buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Git: Undo stage hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Git: Reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Git: Preview hunk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = false })
        end, { desc = "Git: blame line" })
        map("n", "<leader>hd", gs.diffthis, { desc = "Git: Diff against index" })
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, { desc = "Git: Diff against last commit" })

        -- Toggles
        map("n", "<leader>hB", gs.toggle_current_line_blame, { desc = "Git: Toggle blame" })
        map("n", "<leader>hX", gs.toggle_deleted, { desc = "GIT: Toggle show deleted" })

        -- Text object
        map({ "o", "x" }, "<leader>hh", ":<C-U>Gitsigns select_hunk<CR>", { desc = "GIT: Select hunk" })
      end,
    },
  },

}

