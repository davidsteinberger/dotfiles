local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
local util = require("util")

map("n", "<Leader>m", function()
  local root = util.find_root()
  local package_manager = util.detect_package_manager()
  local tsc_cmd = package_manager == "yarn" and "yarn tsc --noEmit" or "npx tsc --noEmit"
  local sed_root = root:gsub('["\\]', "\\%0")
  local cmd = "cd "
    .. vim.fn.shellescape(root)
    .. " && "
    .. util.mise_exec()
    .. " "
    .. tsc_cmd
    .. " 2>&1 | grep -E '^[^/][^(]+\\([0-9]+,[0-9]+\\): (error|warning)' | sed \"s|^|"
    .. sed_root
    .. '/|"'

  util.make_async(cmd, {
    title = "tsc",
    efm = "%f(%l\\,%c): %trror TS%n: %m,%f(%l\\,%c): %tarning TS%n: %m",
  })
end, DEFAULT_OPTIONS)
