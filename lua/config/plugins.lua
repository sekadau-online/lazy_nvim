-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({

  -- UI & Theme
  { "nvim-lualine/lualine.nvim", config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end },
  { "nvim-tree/nvim-tree.lua", config = function()
      require("nvim-tree").setup()
    end },
  { "nvim-tree/nvim-web-devicons" },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000,
    config = function() vim.cmd("colorscheme tokyonight") end },

  -- Code utilities
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- LSP & Completion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", build = ":MasonUpdate", config = function()
      require("mason").setup()
    end },
  { "williamboman/mason-lspconfig.nvim", config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "gopls", "html", "cssls" },
      })
      local lspconfig = require("lspconfig")
      local servers = { "lua_ls", "pyright", "ts_ls", "gopls", "html", "cssls" }
      for _, s in ipairs(servers) do
        lspconfig[s].setup({})
      end
    end },

  -- Autocomplete
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
        }),
      })
    end },
})
