return {
  {
    "folke/noice.nvim",
    -- enabled = false,
    opts = {
      routes = {
        {
          filter = {
            event = "notify",
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
}
