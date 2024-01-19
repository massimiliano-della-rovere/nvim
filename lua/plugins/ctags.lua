local ctags_dir = vim.fn.expand(vim.fn.stdpath("data")) .. "/ctags"


local file_extensions_excluded_from_ctags_generation = {
  "*.git", "*.svg", "*.hg",
  "*/tests/*",
  "build",
  "dist",
  "*sites/*/files/*",
  "bin",
  "node_modules",
  "bower_components",
  "cache",
  "compiled",
  "docs",
  "example",
  "bundle",
  "vendor",
  "*.md",
  "*-lock.json",
  "*.lock",
  "*bundle*.js",
  "*build*.js",
  ".*rc*",
  "*.json",
  "*.min.*",
  "*.map",
  "*.bak",
  "*.zip",
  "*.pyc",
  "*.class",
  "*.sln",
  "*.Master",
  "*.csproj",
  "*.tmp",
  "*.csproj.user",
  "*.cache",
  "*.pdb",
  "tags*",
  "cscope.*",
  "*.css",
  "*.less",
  "*.scss",
  "*.exe", "*.dll",
  "*.mp3", "*.ogg", "*.flac",
  "*.swp", "*.swo",
  "*.bmp", "*.gif", "*.ico", "*.jpg", "*.png",
  "*.rar", "*.zip", "*.tar", "*.tar.gz", "*.tar.xz", "*.tar.bz2",
  "*.pdf", "*.doc", "*.docx", "*.ppt", "*.pptx"
}


return {

  -- ctags generation
  {
    -- https://github.com/ludovicchabant/vim-gutentags
    "ludovicchabant/vim-gutentags",
    config = function()
      vim.g.gutentags_project_root = {
        ".git",
        "package.json",
        "LICENSE",
        "README.md"
      }
      vim.g.gutentags_ctags_tagfile = "ctags"
      if vim.fn.isdirectory(ctags_dir) == 0 then
        vim.fn.mkdir(ctags_dir, "p")
      end
      vim.g.gutentags_cache_dir = ctags_dir
      vim.api.nvim_create_user_command(
        "GutentagsClearCache",
        function()
          if vim.fn.isdirectory(vim.g.gutentags_cache_dir) == 0 then
            vim.fn.mkdir(vim.g.gutentags_cache_dir, "p")
          end
          vim.fn.system("rm " .. vim.g.gutentags_cache_dir .. "/*")
        end,
        { desc = "Gutentags: Clear cache in " .. vim.g.gutentags_cache_dir }
      )
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_empty_buffer = 0
      vim.g.gutentags_ctags_extra_args = { "--tag-relative=yes", "--fields=+ailmnS" }
      vim.g.gutentags_ctags_exclude = file_extensions_excluded_from_ctags_generation
    end
  },

}
