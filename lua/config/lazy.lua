-- =========================
-- Lazy.nvim configuration
-- =========================
require("lazy").setup({
  spec = {
    { import = "plugins.ui" },
    { import = "plugins.lsp" },
    { import = "plugins.coding" },
    { import = "plugins.tools" },
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true }, -- auto update plugin
})
