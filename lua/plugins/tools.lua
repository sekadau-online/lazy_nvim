return {
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Git integration
  { "lewis6991/gitsigns.nvim", config = function()
      require("gitsigns").setup()
    end },

  -- Floating terminal
  { "akinsho/toggleterm.nvim", config = function()
      require("toggleterm").setup({ size = 15, open_mapping = [[<c-\>]] })
    end },
}
