local util = require("util")

return {
  {
    "nvim-neotest/neotest",
    commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c",
    dependencies = {
      "haydenmeade/neotest-jest",
    },
    opts = function(_, opts)
      local commands = {
        yarn = "yarn test",
        pnpm = "pnpm test",
      }
      local jestCommand = commands[util.detect_package_manager()] or "npm test --"

      opts.adapters = vim.tbl_extend("force", opts.adapters, {
        ["neotest-jest"] = {
          jestCommand = jestCommand,
          debug = true,
          cwd = util.find_root,
        },
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
    },
    opts = function(_, opts)
      local commands = {
        yarn = "yarn test",
        pnpm = "pnpm test",
      }
      local vitestCommand = commands[util.detect_package_manager()] or "npm test"

      opts.adapters = vim.tbl_extend("force", opts.adapters, {
        ["neotest-vitest"] = {
          vitestCommand = vitestCommand,
          debug = true,
          cwd = util.find_root,
        },
      })
    end,
  },
}
