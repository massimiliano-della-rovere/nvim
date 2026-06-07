local km = require("keymaps")
-- ============================================================
-- plugins/formatting.lua  --  Neovim 0.12 / 0.13-compatible
-- ============================================================
-- Sostituisce none-ls.nvim (abbandonato dal suo autore):
--
--   conform.nvim  →  formattazione (async, format-on-save, multi-formatter)
--   nvim-lint     →  linting asincrono
--
-- Entrambi installano i tool via mason-tool-installer.nvim.
--
-- KEYMAPS:
--   <leader>lF   formatta con conform (fallback su LSP se mancano formatter)
--   <leader>ll   esegui linter manualmente sul buffer corrente
-- ============================================================

return {

  -- ── conform.nvim: formattazione ───────────────────────────
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      local conform = require("conform")

      conform.setup({
        -- ── Formatter per filetype ──────────────────────────
        -- Lista ordinata: vengono eseguiti in sequenza.
        -- "lsp" usa il formatter del server LSP come fallback.
        formatters_by_ft = {
          python = { "isort", "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          markdown = { "prettier" },
          yaml = { "yamlfmt" },
          lua = { "stylua" },
          sh = { "shfmt" },
          bash = { "shfmt" },
          sql = { "sqlfmt" },
          toml = { "taplo" }, -- gia' gestito da taplo LSP
          -- fallback globale: usa il formatter LSP se disponibile
          ["_"] = { "trim_whitespace" },
        },

        -- ── Format-on-save ───────────────────────────────────
        -- Salva con timeout; non blocca se il formatter e' lento.
        -- format_on_save: rispetta il toggle <leader>lf.
        -- vim.b[bufnr].conform_format_on_save:
        --   nil    = default (ON)
        --   false  = disabilitato per questo buffer (<leader>lf)
        format_on_save = function(bufnr)
          if vim.b[bufnr].conform_format_on_save == false then
            return nil
          end
          if vim.bo[bufnr].buftype ~= "" then
            return nil
          end
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok and stats and stats.size > 500 * 1024 then
            return nil
          end
          return { timeout_ms = 3000, lsp_fallback = true }
        end,

        -- ── Notifica errori del formatter ────────────────────
        notify_on_error = true,

        -- ── Formatter custom / override ──────────────────────
        formatters = {
          -- ── Python: black e isort ────────────────────────────
          -- black e isort leggono la config da pyproject.toml del
          -- progetto (o da ~/.config/pyproject.toml come global).
          -- Non passiamo prepend_args: la config del progetto ha
          -- la precedenza e permette impostazioni diverse per repo.
          --
          -- pyproject.toml minimo consigliato:
          --   [tool.black]
          --   line-length = 80
          --
          --   [tool.isort]
          --   profile     = "black"
          --   line_length = 80
          black = {
            prepend_args = {
              "--line-length",
              "80",
            },
          },
          isort = {
            prepend_args = {
              "--profile",
              "black",
            },
          },
          -- ── Prettier: usa config del progetto ─────────────
          prettier = {
            prepend_args = {
              "--use-tabs=false",
              "--tab-width=2",
            },
            require_cwd = true, -- non usa prettier globale se non c'e' config
            cwd = require("conform.util").root_file({
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.js",
              ".prettierrc.yaml",
              ".prettierrc.yml",
              "prettier.config.js",
              "package.json",
            }),
          },
          -- shfmt: per la BASh
          shfmt = {
            prepend_args = {
              "-i",
              "2",
            },
          },
          -- sqlfmt: formattatore SQL moderno
          sqlfmt = {
            command = "sqlfmt",
            args = { "-" },
            stdin = true,
          },
          -- lua (e file di configurazione neovim)
          stylua = {
            prepend_args = {
              "--indent-type",
              "Spaces",
              "--indent-width",
              "2",
            },
          },
          -- yaml
          yamlfmt = {
            prepend_args = {
              "-formatter.indent=2",
            },
          },
        },
      })

      -- ── Keymap: formatta manualmente ─────────────────────
      vim.keymap.set({ "n", "v" }, km.lsp .. "F", function()
        conform.format({
          async = true,
          lsp_fallback = true,
          timeout_ms = 5000,
        })
      end, { desc = "Format: conform (async)" })

      -- ── Keymap: toggle format-on-save ────────────────────
      vim.keymap.set("n", km.lsp .. "f", function()
        if vim.b.conform_format_on_save == false then
          vim.b.conform_format_on_save = nil -- reset a default (ON)
          vim.notify("Format on save: ON", vim.log.levels.INFO)
        else
          vim.b.conform_format_on_save = false -- disabilita
          vim.notify("Format on save: OFF", vim.log.levels.WARN)
        end
      end, { desc = "Format: toggle format-on-save" })
    end,
  },

  -- ── nvim-lint: linting asincrono ─────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python = { "flake8" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        lua = { "luacheck" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        yaml = { "yamllint" },
        markdown = { "markdownlint" },
      }

      -- Esegui il linter dopo salvataggio, lettura e focus
      local lint_group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_group,
        callback = function()
          -- Evita linting su buffer speciali
          if vim.bo.buftype == "" then
            lint.try_lint()
          end
        end,
      })

      vim.keymap.set("n", km.lsp .. "l", function()
        lint.try_lint()
      end, { desc = "Lint: run on buffer" })
    end,
  },

  -- ── mason-tool-installer: installa formatter/linter ──────
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Formatter
          "black", -- Python
          "isort", -- Python imports
          "prettier", -- JS/TS/CSS/HTML/JSON/Markdown
          "stylua", -- Lua
          "yamlfmt", -- YAML
          "shfmt", -- Shell
          "sqlfmt", -- SQL
          -- Linter
          "flake8", -- Python
          "eslint_d", -- JS/TS (daemon, veloce)
          "luacheck", -- Lua
          "shellcheck", -- Shell
          "yamllint", -- YAML
          "markdownlint", -- Markdown
        },
        auto_update = false,
        run_on_config = true,
      })
    end,
  },
}
