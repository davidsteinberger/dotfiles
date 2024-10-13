return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local pnp = vim.fn.findfile(".pnp.cjs", ".;")
      local is_pnp = pnp ~= ""
      if is_pnp then
        vim.fn.system("yarn bin prettier")
        if vim.v.shell_error ~= 0 then
          return
        end
        pnp = vim.fn.fnamemodify(pnp, ":p")
        -- local root = pnp:gsub(".pnp.cjs", "")
        local yarn_bin = vim.fn.system("yarn bin prettier"):gsub("%s+", "")
        local prettier = require("conform.formatters.prettier")
        prettier.command = "node"
        prettier.args = {
          "--require",
          -- root .. ".pnp.cjs",
          pnp,
          yarn_bin,
          "--stdin-filepath",
          "$FILENAME",
        }
      end
      opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft, {
        ["javascript"] = { "prettier" },
        ["javascriptreact"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["typescriptreact"] = { "prettier" },
        ["vue"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["json"] = { "prettier" },
        ["jsonc"] = { "prettier" },
        ["yaml"] = { "prettier" },
        ["markdown"] = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        ["graphql"] = { "prettier" },
        ["handlebars"] = { "prettier" },
        ["python"] = { "black" },
      })
    end,
  },
}
