return {
  {
    "folke/noice.nvim",
    enabled = false,
    opts = {
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "No information available" },
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%d fewer lines" },
              { find = "%d more lines" },
            },
          },
          opts = { skip = true },
        },
      },
    },
  },
  -- {
  --   "echasnovski/mini.animate",
  --   opts = {
  --     open = {
  --       enable = false,
  --     },
  --     close = {
  --       enable = false,
  --     },
  --   },
  -- },
  -- lazy.nvim
  -- {
  --   "folke/snacks.nvim",
  --   opts = {
  --     zen = {
  --       -- your zen configuration comes here
  --       -- or leave it empty to use the default settings
  --       -- refer to the configuration section below
  --     },
  --   },
  -- },
}
