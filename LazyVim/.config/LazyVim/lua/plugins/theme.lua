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
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },

        -- Save an hlgroup with dark background and dimmed foreground
        -- so that you can use it where your still want darker windows.
        -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
        NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

        -- Popular plugins that open floats will link to NormalFloat by default;
        -- set their background accordingly if you wish to keep them dark and borderless
        LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

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
  local kanagawa = require("kanagawa")
  ---@diagnostic disable-next-line: missing-fields
  kanagawa.setup({ theme = "lotus", transparent = false })
  vim.cmd("colorscheme kanagawa-lotus")
end

return {
  {
    "rebelot/kanagawa.nvim",
    config = function()
      DarkMode()
    end,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "kanagawa",
        callback = function()
          vim.api.nvim_set_hl(0, "StatusLine", { link = "lualine_c_normal" })
        end,
      })
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
