return {

  -- startup screen with MRU files
  {
    -- https://github.com/goolord/alpha-nvim
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.startify")
      alpha.setup(dashboard.config)

      vim.keymap.set("n", "<leader>i", "<CMD>Alpha<CR>", { desc = "Show dashboard" })
    end,
  },

}
