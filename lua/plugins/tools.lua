return {
  -- Dependensi umum
  { "nvim-lua/plenary.nvim" },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { width = 0.9, height = 0.8 },
        },
      })
    end,
  },
}
