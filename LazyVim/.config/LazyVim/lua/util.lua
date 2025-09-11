local M = {}
local util = require("lspconfig").util

function M.find_root()
  return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")(vim.api.nvim_buf_get_name(0))
end

function M.detect_package_manager()
  local root = M.find_root()
  if not root then
    return "npm"
  end

  if vim.fn.filereadable(root .. "/pnpm-lock.yaml") == 1 then
    return "pnpm"
  elseif vim.fn.filereadable(root .. "/yarn.lock") == 1 then
    return "yarn"
  else
    return "npm"
  end
end

return M
