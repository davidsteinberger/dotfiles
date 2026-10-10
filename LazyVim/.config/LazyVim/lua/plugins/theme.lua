-- @param transparent: boolean?
function DarkMode(transparent)
  local kanagawa = require("kanagawa")
  ---@diagnostic disable-next-line: missing-fields
  kanagawa.setup({
    theme = "wave",
    transparent = transparent or false,
    colors = {
      theme = {
        all = {
          ui = {
            bg_gutter = "none",
          },
        },
      },
    },
    overrides = function(colors)
      local theme = colors.theme
      return {
        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
        PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
        PmenuSbar = { bg = theme.ui.bg_m1 },
        PmenuThumb = { bg = theme.ui.bg_p2 },
      }
    end,
  })
  vim.cmd("colorscheme kanagawa-wave")
end

function LightMode()
  require("catppuccin").setup({ flavour = "latte", transparent_background = false })
  vim.cmd("colorscheme catppuccin-latte")
end

return {
  {
    "rebelot/kanagawa.nvim",
    config = function()
      DarkMode()
    end,
    opts = {
      ---@param colors KanagawaColors
      overrides = function(colors)
        return {
          StatusLine = { bg = colors.theme.ui.bg_p1 },
        }
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
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
    opts = {
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
