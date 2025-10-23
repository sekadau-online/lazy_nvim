return {
  -- Core LSP config
  { "neovim/nvim-lspconfig" },

  -- Mason: installer server LSP
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  -- Integrasi Mason dengan LSPConfig
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "gopls", "html", "cssls" },
      })

      local lspconfig = require("lspconfig")
      local servers = { "lua_ls", "pyright", "ts_ls", "gopls", "html", "cssls" }
      for _, s in ipairs(servers) do
        lspconfig[s].setup({})
      end
    end,
  },
}
