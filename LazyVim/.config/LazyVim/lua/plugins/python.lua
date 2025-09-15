return {
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      if vim.fn.has("win32") == 1 then
        require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
      else
        require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
      end
      for _, config in ipairs(require("dap").configurations.python) do
        config.cwd = "${workspaceFolder}"
      end
    end,
  },
}
