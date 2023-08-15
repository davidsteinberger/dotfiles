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
  {
    "f-person/auto-dark-mode.nvim",
    config = {
      update_interval = 1000,
      set_dark_mode = function()
        require("kanagawa").setup({ theme = "wave", transparent = true })
        vim.api.nvim_set_option("background", "dark")
      end,
      set_light_mode = function()
        require("kanagawa").setup({ theme = "lotus", transparent = false })
        vim.api.nvim_set_option("background", "light")
      end,
    },
  },
}
