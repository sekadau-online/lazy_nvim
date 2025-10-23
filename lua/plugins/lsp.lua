return {
  -- Core LSP (wajib)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  -- Mason untuk menginstall LSP server
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  -- Integrasi Mason + LSPConfig (modern API)
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "gopls", "html", "cssls" },
      })

      -- Daftar server yang ingin diaktifkan
      local servers = { "lua_ls", "pyright", "ts_ls", "gopls", "html", "cssls" }

      -- Konfigurasi baru: gunakan vim.lsp.config
      for _, name in ipairs(servers) do
        vim.lsp.config[name] = {
          cmd = { name },
          capabilities = vim.lsp.protocol.make_client_capabilities(),
          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          end,
        }

        -- Aktifkan server
        vim.lsp.enable(name)
      end
    end,
  },
}
