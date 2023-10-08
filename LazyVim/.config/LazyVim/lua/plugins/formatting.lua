return {
  {
    "stevearc/conform.nvim",
    opts = function()
      local is_pnp = vim.fn.findfile(".pnp.cjs", ".;") ~= ""
      if is_pnp then
        local yarn_bin = vim.fn.system("yarn bin prettier"):gsub("%s+", "")
        local prettier = require("conform.formatters.prettier")
        prettier.command = "node"
        prettier.args = {
          "--require",
          "./.pnp.cjs",
          yarn_bin,
          "--stdin-filepath",
          "$FILENAME",
        }
      end
      return {
        formatters_by_ft = {
          ["javascript"] = { { "prettier" } },
          ["javascriptreact"] = { { "prettier" } },
          ["typescript"] = { { "prettier" } },
          ["typescriptreact"] = { { "prettier" } },
          ["vue"] = { { "prettier" } },
          ["css"] = { { "prettier" } },
          ["scss"] = { { "prettier" } },
          ["less"] = { { "prettier" } },
          ["html"] = { { "prettier" } },
          ["json"] = { { "prettier" } },
          ["jsonc"] = { { "prettier" } },
          ["yaml"] = { { "prettier" } },
          ["markdown"] = { { "prettier" } },
          ["markdown.mdx"] = { { "prettier" } },
          ["graphql"] = { { "prettier" } },
          ["handlebars"] = { { "prettier" } },
          ["python"] = { { "black" } },
        },
      }
    end,
  },
}
