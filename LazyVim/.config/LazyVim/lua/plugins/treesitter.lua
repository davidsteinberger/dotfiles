return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      opts.incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "v",
          node_decremental = "V",
          scope_incremental = "<M-v>",
        },
      }
      vim.list_extend(opts.ensure_installed, {
        "graphql",
      })
    end,
  },
}
