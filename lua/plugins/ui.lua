return {
  { "folke/tokyonight.nvim", lazy = false, priority = 1000,
    config = function() vim.cmd("colorscheme tokyonight") end },

  { "nvim-lualine/lualine.nvim", config = function()
      require("lualine").setup({ options = { theme = "auto" } })
    end },

  { "nvim-tree/nvim-tree.lua", config = function()
      require("nvim-tree").setup()
    end },

  { "nvim-tree/nvim-web-devicons" },

  { "nvim-lualine/lualine.nvim" },
}
