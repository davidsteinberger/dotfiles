return {
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = { find = "No information available" },
          opts = { stop = true },
        },
      },
      -- lsp = {
      --   hover = {
      --     enabled = false,
      --   },
      -- },
    },
  },
}
