return {
  {
    "nvim-neotest/neotest",
    commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c",
    dependencies = {
      "haydenmeade/neotest-jest",
      -- Your other test adapters here
    },
    opts = function(_, opts)
      local jestCommand = "npm test --"
      local yarnLockFile = vim.fn.findfile("yarn.lock", ".;")
      local hasYarn = yarnLockFile ~= ""
      if hasYarn then
        jestCommand = "yarn test"
      end
      opts.adapters = vim.tbl_extend("force", opts.adapters, {
        ["neotest-jest"] = {
          jestCommand = jestCommand,
          debug = true,
          -- env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
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
        ["neotest-vitest"] = {},
      },
    },
  },
}
