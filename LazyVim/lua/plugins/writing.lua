return {
  {
    {
      "williamboman/mason.nvim",
      opts = {
        ensure_installed = {
          "proselint",
          "write-good",
          "alex",
        },
      },
    },
    {
      "jose-elias-alvarez/null-ls.nvim",
      opts = function(_, opts)
        local nls = require("null-ls")
        opts.sources = vim.list_extend(opts.sources, {
          nls.builtins.diagnostics.proselint,
          nls.builtins.code_actions.proselint,
          nls.builtins.diagnostics.alex,
          nls.builtins.diagnostics.write_good,
        })
      end,
    },
    {
      "iamcco/markdown-preview.nvim",
      ft = "markdown",
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
    },
  },
}
