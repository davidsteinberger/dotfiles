local util = require("util")

return {
  {
    "nvim-neotest/neotest",
    commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c",
    dependencies = {
      "haydenmeade/neotest-jest",
    },
    opts = function(_, opts)
      local package_manager = util.detect_package_manager()
      local jestCommand = "npm test --"
      if package_manager == "yarn" then
        jestCommand = "yarn test"
      elseif package_manager == "pnpm" then
        jestCommand = "pnpm test"
      end

      opts.adapters = vim.tbl_extend("force", opts.adapters, {
        ["neotest-jest"] = {
          jestCommand = jestCommand,
          debug = true,
          cwd = function()
            return util.find_root()
          end,
        },
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {
          debug = true,
          cwd = function()
            return util.find_root()
          end,
        },
      },
    },
  },
}
