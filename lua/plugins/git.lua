return {

  -- git integration
  "tpope/vim-fugitive",

  -- git :GBrowse
  "tpope/vim-rhubarb",

  -- git operation symbols on the symbol bar
  "airblade/vim-gitgutter",

  -- git blame
  { "f-person/git-blame.nvim", event = "VeryLazy" },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        -- vim.keymap.set(
        --   "n", "<leader>hp",
        --   require("gitsigns").preview_hunk,
        --   { buffer = bufnr, desc = "Git: [H]unk [P]review" })
        -- vim.keymap.set(
        --   "n", "<leader>hs",
        --   ":GitGutterStageHunk",
        --   { buffer = bufnr, desc = "Git: [H]unk [S]tage" })
        -- vim.keymap.set(
        --   "n", "<leader>hu",
        --   ":GitGutterUndoHunk",
        --   { buffer = bufnr, desc = "Git: [H]unk [U]ndo" })

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
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end,
          { expr = true, buffer = bufnr, desc = "Git: to next [C]hange" })
        vim.keymap.set(
          { "n", "v" }, "[c",
          function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end,
          { expr = true, buffer = bufnr, desc = "Git: to prev [C]hange" })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

}
