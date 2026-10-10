local map = vim.keymap.set
DEFAULT_OPTIONS = { noremap = true, silent = true }
map("n", "<Leader>m", "<Cmd>ConjureEvalRootForm<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cj", "<Cmd>Clj!<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cef", "<Cmd>ConjureEvalFile<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cee", "<Cmd>ConjureEvalCurrentForm<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cer", "<Cmd>ConjureEvalRootForm<CR>", DEFAULT_OPTIONS)
map("n", "<Leader>cc", "<Cmd>ConjureConnect<CR>", DEFAULT_OPTIONS)

-- Conjure: <localleader>eco evaluates the form under the cursor and replaces it
-- with what it printed to stdout (e.g. s/print-constructors), as ";; " comment
-- lines. Conjure's own e! would replace it with the return value (nil).
vim.keymap.set("n", "<localleader>eco", function()
  local eval = require("conjure.eval")
  local extract = require("conjure.extract")
  local buffer = require("conjure.buffer")
  local buf = vim.api.nvim_get_current_buf()
  local form = extract.form({})
  if not form then
    return
  end
  eval["eval-str"]({
    code = "(with-out-str " .. form.content .. ")",
    range = form.range,
    node = form.node,
    origin = "replace-form-out",
    ["suppress-hud?"] = true,
    ["on-result"] = function(result)
      -- the result is a pr-str'd Clojure string, its escapes match JSON's
      local ok, out = pcall(vim.json.decode, result)
      if not ok or type(out) ~= "string" or out == "" then
        vim.notify("Conjure eco: no stdout output to insert", vim.log.levels.WARN)
        return
      end
      local lines = {}
      for line in vim.gsplit(vim.trim(out), "\n", { plain = true }) do
        table.insert(lines, (((";; " .. line):gsub("%s+$", ""))))
      end
      buffer["replace-range"](buf, form.range, table.concat(lines, "\n"))
    end,
  })
end, { buffer = true, desc = "Conjure: replace form with its stdout as comment" })
