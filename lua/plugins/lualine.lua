return {
  {
    -- Set lualine as statusline
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- See `:help lualine.txt`
    opts = {
      options = {
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
        lualine_c = { { "filename", path = 3 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress", "filesize", "searchcount" },
        lualine_z = { "location", "selectioncount"  },
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
        lualine_a = { "'b'", { "buffers", mode = 4, use_mode_colors = true } },
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "'w'", { "windows", mode = 2, use_mode_colors = true } },
        lualine_y = { "'t'", { "tabs", mode = 2, use_mode_colors = true } },
        lualine_z = { "hostname", { "datetime", style = "%Y-%m-%d %H:%M:%S" } },
      },
      -- winbar = {
      --   lualine_a = { { "windows", mode = 2 } },
      --   lualine_b = {},
      --   lualine_c = {},
      --   lualine_x = { "searchcount" },
      --   lualine_y = {},
      --   lualine_z = { "selectioncount" },
      -- },
      -- inactive_winbar = {
      --   lualine_a = { { "windows", mode = 0 } },
      --   lualine_b = {},
      --   lualine_c = {},
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = {},
      -- }
    },
  },
}
