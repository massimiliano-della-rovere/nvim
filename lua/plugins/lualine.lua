return {

  -- better status line
  {
    -- https://github.com/nvim-lualine/lualine.nvim
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        extensions = { "aerial", "fugitive", "lazy", "mason", "mundo", "neo-tree", "nvim-dap-ui", "oil" },
        options = {
          theme = "dracula",
          icons_enabled = true,
          -- theme = "onedark",
          -- component_separators = { left = "", right = ""}, -- = "|",
          -- section_separators = { left = "", right = ""}, -- = "",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" }
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 3 }, },
          lualine_x = { "%{gutentags#statusline()}", "encoding", "fileformat", "filetype" },
          lualine_y = { "progress", "selectioncount" },
          lualine_z = { "location", "searchcount" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {
          lualine_a = { "'b:'", { "buffers", mode = 4, use_mode_colors = true }, },
          lualine_y = { "hostname", { "datetime", style = "%F/%a w%V %T@%z" }, },
          lualine_z = { "'t:'", { "tabs", mode = 2, se_mode_colors = true }, },
        },
        winbar = {
          lualine_b = { "aerial" },
          lualine_z = { "'w:'", { "windows", mode = 2, use_mode_colors = true } },
        }
      })

      vim.keymap.set(
        "n", "<leader>rt",
        function()
          vim.fn.execute(":LualineRenameTab " .. vim.fn.input("Enter tab name: "))
        end,
        { desc = "Lualine: Rename Tab" })
    end
  },

}
