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
        "cmake",
        "css",
        "devicetree",
        "gitcommit",
        "gitignore",
        "go",
        "graphql",
        "http",
        "kconfig",
        "ninja",
        "nix",
        "scss",
        "sql",
        "yaml",
      })
    end,
  },
}
