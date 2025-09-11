local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
local util = require("util")

map("n", "<Leader>m", function()
  local root = util.find_root()
  local package_manager = util.detect_package_manager()
  local tsc_cmd = "run tsc --noEmit"
  if package_manager == "npm" then
    tsc_cmd = "run tsc -- --noEmit"
  else
    tsc_cmd = "run tsc --noEmit"
  end
  local makeprg = "cd "
    .. vim.fn.shellescape(root)
    .. " && "
    .. package_manager
    .. " "
    .. tsc_cmd
    .. " 2>&1 | sed -r 's|^(src)|"
    .. vim.fn.shellescape(root)
    .. "\\//\\1|g'"

  vim.cmd.compiler("tsc")
  vim.o.makeprg = makeprg
  vim.cmd("Make")
end, DEFAULT_OPTIONS)
