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
        local sources = {}
        for _, v in pairs(opts.sources) do
          if v.name ~= "stylua" and v.name ~= "fish" and v.name ~= "shfmt" then
            sources[#sources + 1] = v
          end
        end
        opts.sources = vim.list_extend(sources, {
          nls.builtins.diagnostics.proselint,
          nls.builtins.code_actions.proselint,
          nls.builtins.diagnostics.alex,
          nls.builtins.diagnostics.write_good,
        })
      end,
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
