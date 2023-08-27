function DarkMode()
  require("kanagawa").setup({
    theme = "wave",
    transparent = true,
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
  vim.api.nvim_set_option("background", "dark")
end

function LightMode()
  require("kanagawa").setup({ theme = "lotus", transparent = false })
  vim.api.nvim_set_option("background", "light")
end

return {
  {
    "rebelot/kanagawa.nvim",
    config = function()
      DarkMode()
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
        DarkMode()
      end,
      set_light_mode = function()
        LightMode()
      end,
    },
  },
}
