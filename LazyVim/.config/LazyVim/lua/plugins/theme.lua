-- @param transparent: boolean?
function DarkMode(transparent)
  local kanagawa = require("kanagawa")
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
    overrides = function(colors) -- add/modify highlights
      local theme = colors.theme
      local obj = {
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },

        NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend }, -- add `blend = vim.o.pumblend` to enable transparency
        PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
        PmenuSbar = { bg = theme.ui.bg_m1 },
        PmenuThumb = { bg = theme.ui.bg_p2 },
      }
      if transparent == true then
        obj.NormalFloat = { bg = "none" }
      end
      return obj
    end,
  })
  kanagawa.load()
  vim.api.nvim_set_option_value("background", "dark", {})
  vim.cmd("highlight TelescopeBorder guibg=none")
  vim.cmd("highlight TelescopeTitle guibg=none")
  -- local colors = require("kanagawa.colors").setup({ theme = "wave" })
  -- local theme_colors = colors.theme
  -- vim.cmd("highlight DiffDelete guifg=" .. theme_colors.ui.fg_dim .. " guibg=none")
end

function LightMode()
  local kanagawa = require("kanagawa")
  kanagawa.setup({ theme = "lotus", transparent = false })
  kanagawa.load()
  vim.api.nvim_set_option_value("background", "light", {})
  -- local colors = require("kanagawa.colors").setup({ theme = "lotus" })
  -- local theme_colors = colors.theme
  -- vim.cmd("highlight DiffDelete guifg=" .. theme_colors.ui.bg .. " guibg=none")
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
