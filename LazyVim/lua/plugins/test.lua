return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "haydenmeade/neotest-jest",
      -- Your other test adapters here
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "yarn test",
          debug = true,
          -- env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },
}
