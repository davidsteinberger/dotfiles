-- Fallback: plain cider-nrepl `complete` (compliment) for everything the
-- reflection path can't name a class for (Clojure vars, keywords, classes, ...).
local nrepl = require("conjure_blink.nrepl")

local M = {}

local TYPE_KIND = {
  class = "Class", field = "Field", ["static-field"] = "Field", method = "Method",
  ["static-method"] = "Method", ["function"] = "Function", macro = "Function",
  ["special-form"] = "Keyword", keyword = "Keyword", ["local"] = "Variable",
  namespace = "Module", resource = "File", var = "Variable",
}

-- Conjure's own context splice leaves the typed text in front of `__prefix__`
-- (`(.toEpo__prefix__ x)`), which compliment can't use. Replace the whole word.
local function completion_context(prefix, row, col)
  local ok, form = pcall(function()
    return require("conjure.extract").form({ ["root?"] = true })
  end)
  if not ok or not form then
    return nil
  end
  local lines = vim.split(form.content, "\n", { plain = true })
  local lrow = row - form.range.start[1]
  local lcol = lrow == 0 and (col - form.range.start[2]) or col
  local line = lines[lrow + 1]
  if not line then
    return nil
  end
  lines[lrow + 1] = line:sub(1, lcol - #prefix) .. "__prefix__" .. line:sub(lcol + 1)
  return table.concat(lines, "\n")
end

--- cb(items)
function M.complete(prefix, row, col, ns, range, Kinds, cb)
  if not nrepl.has_op("complete") then
    return cb({})
  end
  -- compliment matches prefixes case-sensitively: ask up to the member
  -- separator and let blink's fuzzy matcher narrow the rest.
  local query = prefix:match("^%.") and "." or prefix:match("^(.*/)") or prefix
  nrepl.send({
    op = "complete",
    ns = ns,
    symbol = query,
    context = completion_context(prefix, row, col),
    ["extra-metadata"] = { "arglists", "doc" },
  }, function(msgs)
    local items = {}
    for _, msg in ipairs(msgs or {}) do
      for _, c in ipairs(msg.completions or {}) do
        local details = {}
        if c.ns then
          details[#details + 1] = c.ns
        end
        if type(c.arglists) == "table" then
          details[#details + 1] = table.concat(c.arglists, " ")
        end
        local item = {
          label = c.candidate,
          kind = Kinds[TYPE_KIND[c.type] or "Text"],
          textEdit = { newText = c.candidate, range = range },
        }
        if #details > 0 then
          item.labelDetails = { description = table.concat(details, " ") }
        end
        if type(c.doc) == "string" and c.doc ~= "" then
          item.documentation = { kind = "plaintext", value = c.doc }
        end
        items[#items + 1] = item
      end
    end
    cb(items)
  end)
end

return M
