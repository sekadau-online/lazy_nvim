return {
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Auto pairs
  { "windwp/nvim-autopairs", config = function()
      require("nvim-autopairs").setup()
    end },

  -- Comment toggler
  { "numToStr/Comment.nvim", config = true },
}
