local km = require("keymaps")
local python_env = require("utils.python_env")
local is_python2 = python_env.is_python2()

-- Su ambienti Python 2.x, i seguenti tool non sono compatibili
-- e vengono esclusi da formatter, linter e installazione Mason:
--
--   black, isort  → Python 3.6+
--   flake8        → Python 3.6+
--   sqlfmt        → Python 3.8+
--   yamllint      → Python 3.10+
--
-- Nota: yamlfmt (Go), shfmt (Go), prettier (npm), stylua (Rust),
-- shellcheck (Haskell), eslint_d (npm), luacheck (Lua),
-- markdownlint (npm) non dipendono da Python e restano attivi.
--
-- jedi-language-server (mason_lsp.lua) fornisce diagnostics
-- di base per Python come sostituto di flake8.
local python_formatters = is_python2 and {} or { "isort", "black" }
local python_linters    = is_python2 and {} or { "flake8" }
local sql_formatters    = is_python2 and {} or { "sqlfmt" }
local yaml_linters      = is_python2 and {} or { "yamllint" }
local python_tools      = is_python2 and {} or { "black", "isort", "flake8" }
local sql_tools         = is_python2 and {} or { "sqlfmt" }
local yaml_lint_tools   = is_python2 and {} or { "yamllint" }

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
          python = python_formatters,
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
          sql = sql_formatters,
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
              "--indent",
              "2",
              "--case-indent",
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
        python = { "pflake8" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        lua = { "luacheck" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        yaml = yaml_linters,
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
        ensure_installed = vim.list_extend(
          vim.list_extend(
            vim.list_extend({
              -- Formatter (sempre installati, non dipendono da Python)
              "prettier",     -- JS/TS/CSS/HTML/JSON/Markdown  (npm)
              "stylua",       -- Lua                           (Rust)
              "yamlfmt",      -- YAML                          (Go)
              "shfmt",        -- Shell                         (Go)
              -- Linter (sempre installati)
              "eslint_d",     -- JS/TS                         (npm)
              "luacheck",     -- Lua                           (Lua)
              "shellcheck",   -- Shell                         (Haskell)
              "markdownlint", -- Markdown                      (npm)
            }, python_tools),    -- black, isort, flake8  (skip su py2)
          sql_tools),            -- sqlfmt                (skip su py2)
        yaml_lint_tools),        -- yamllint              (skip su py2)
        auto_update = false,
        run_on_config = true,
      })
    end,
  },
}
