return {
  { "haydenmeade/neotest-jest" },
  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    dependencies = {
      "nvim-neotest/neotest-go",
      "neotest-python",
      "haydenmeade/neotest-jest",
      -- Your other test adapters here
    },
    keys = {},
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "yarn test",
          -- debug = true,
          -- env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
        "neotest-go",
        ["neotest-python"] = {
          -- Extra arguments for nvim-dap configuration
          -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
          dap = {
            justMyCode = false,
            console = "integratedTerminal",
          },
          args = { "--log-level", "DEBUG", "--quiet" },
          runner = "pytest",
        },
      },
    },
  },
}
