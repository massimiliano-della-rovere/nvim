return {

	-- DB UI
	{
    -- https://github.com/kristijanhusak/vim-dadbod-ui
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
      
      -- DB engine
			{
        -- https://github.com/tpope/vim-dadbod
				"tpope/vim-dadbod",
				lazy = true,
				config = function()
					-- vim.g.db_ui_save_location = vim.fn.stdpath("config" .. require("plenary.path").path.sep .. "db_ui")
				end,
			},

      -- Autocompletion / cmp plugin using DB stuff as source
			{
        -- https://github.com/kristijanhusak/vim-dadbod-completion
				"kristijanhusak/vim-dadbod-completion",
				ft = { "sql", "mysql", "plsql" },
				lazy = true,
				config = function()
					vim.api.nvim_create_autocmd("FileType", {
						pattern = { "sql" },
						command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
					})

					local function db_completion()
						require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
					end

					local autocomplete_group = vim.api.nvim_create_augroup("vimrc_autocompletion", { clear = true })
					vim.api.nvim_create_autocmd("FileType", {
						pattern = { "sql", "mysql", "plsql" },
						group = autocomplete_group,
						callback = function()
							-- vim.schedule(db_completion)
							require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
						end,
					})
				end,
			},
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		build = ":TSInstall sql",
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1

			vim.api.nvim_set_keymap(
				"n",
				"<leader>ba",
				":DBUIAddConnection<CR>",
				{ noremap = true, desc = "DB Add connection" }
			)

			vim.api.nvim_set_keymap(
        "n", "<leader>bu",
        ":DBUIToggle<CR>",
        { noremap = true, desc = "DB toggle UI" })

			vim.api.nvim_set_keymap(
				"n",
				"<leader>bf",
				":DBUIFindBuffer<CR>",
				{ noremap = true, desc = "DB Find buffer" }
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>br",
				":DBUIRenameBuffer<CR>",
				{ noremap = true, desc = "DB Rename buffer" }
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>bq",
				":DBUILastQueryInfo<CR>",
				{ noremap = true, desc = "DB last Query info" }
			)
		end,
	},

}
