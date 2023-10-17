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
      "nvimtools/none-ls.nvim",
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
      "lukas-reineke/headlines.nvim",
      optional = true,
      opts = function()
        local opts = {}
        for _, ft in ipairs({ "markdown", "norg", "rmd", "org" }) do
          opts[ft] = {
            fat_headlines = false,
            headline_highlights = {},
          }
          for i = 1, 2 do
            table.insert(opts[ft].headline_highlights, "Headline" .. i)
          end
        end
        print(opts)
        return opts
      end,
      ft = { "markdown", "norg", "rmd", "org" },
    },
  },
  {
    "NStefan002/speedtyper.nvim",
    branch = "main",
    cmd = "Speedtyper",
    opts = {
      -- your config
    },
  },
}
