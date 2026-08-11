local M = {}
local util = require("lspconfig").util

function M.find_root()
  return util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(vim.api.nvim_buf_get_name(0))
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

function M.mise_exec()
  return "mise exec --"
end

-- Runs cmd asynchronously, parses stdout with efm, and populates the quickfix list.
-- opts:
--   title  (string) quickfix list title
--   efm    (string) errorformat string
function M.make_async(cmd, opts)
  local title = opts.title or cmd
  local efm = opts.efm or vim.o.errorformat
  local lines = {}

  vim.fn.setqflist({}, " ", {
    title = title,
    items = { { text = title .. ": running...", valid = false } },
  })
  vim.cmd("copen")

  vim.fn.jobstart({ "sh", "-c", cmd }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(lines, line)
        end
      end
    end,
    on_exit = function()
      vim.schedule(function()
        vim.fn.setqflist({}, " ", {
          title = title,
          lines = lines,
          efm = efm,
        })
        vim.api.nvim_exec_autocmds("QuickFixCmdPost", { pattern = "make" })
        vim.cmd("cwindow")
        local qf = vim.fn.getqflist()
        local valid = vim.tbl_filter(function(e)
          return e.valid == 1
        end, qf)
        if #valid == 0 then
          vim.notify(title .. ": no errors", vim.log.levels.INFO)
        else
          vim.notify(title .. ": " .. #valid .. " issue(s)", vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

function M.is_yarn_pnp()
  local root = M.find_root()
  if not root then
    return false
  end
  return vim.fn.filereadable(root .. "/.pnp.cjs") == 1
end

return M
