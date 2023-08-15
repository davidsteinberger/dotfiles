return {
  {
    "rebelot/kanagawa.nvim",
    config = function()
      require("kanagawa").setup({
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
      })
      require("kanagawa").load("wave")
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    event = "VeryLazy",
    config = function()
      require("catppuccin").setup({
        transparent_background = false,
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    event = "VeryLazy",
  },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
