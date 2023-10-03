return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local null_ls = require("null-ls")

      local command_resolver = require("null-ls.helpers.command_resolver")
      local is_pnp = vim.fn.findfile(".pnp.cjs", ".;") ~= ""

      local with_yarn_pnp = function(source)
        return source.with({
          dynamic_command = is_pnp and command_resolver.from_yarn_pnp() or nil,
        })
      end
      table.insert(opts.sources, with_yarn_pnp(null_ls.builtins.formatting.prettier))
    end,
  },
}
