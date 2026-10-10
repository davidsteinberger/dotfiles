-- Builds blink completion items from reflected class members.
local reflect = require("conjure_blink.reflect")

local M = {}

local function simple(name)
  if not name then
    return "?"
  end
  local dims = 0
  while name:sub(1, 1) == "[" do
    dims = dims + 1
    name = name:sub(2)
  end
  local prim = { Z = "boolean", B = "byte", C = "char", D = "double", F = "float", I = "int", J = "long", S = "short" }
  if dims > 0 then
    name = prim[name] or name:gsub("^L", ""):gsub(";$", "")
  end
  return (name:match("([^.$]+)$") or name) .. string.rep("[]", dims)
end
M.simple = simple

local function sig(m)
  local ps = {}
  for _, p in ipairs(m.params) do
    ps[#ps + 1] = simple(p)
  end
  return "(" .. table.concat(ps, ", ") .. ")"
end

local function docs(info, name, overloads, field)
  local lines = {}
  if field then
    lines[1] = (field.static and "static " or "") .. simple(field.type) .. " " .. name
  else
    for _, m in ipairs(overloads) do
      lines[#lines + 1] = (m.static and "static " or "") .. simple(m.ret) .. " " .. name .. sig(m)
    end
  end
  return "**" .. info.fq .. "**\n```java\n" .. table.concat(lines, "\n") .. "\n```"
end

local function method_item(info, label, name, overloads, nargs, range, Kinds)
  local exact = {}
  if nargs and nargs > 0 then
    for _, m in ipairs(overloads) do
      if #m.params == nargs then
        exact[#exact + 1] = m
      end
    end
  end
  local shown = exact[1] or overloads[1]
  local more = #overloads > 1 and (" +" .. (#overloads - 1)) or ""
  local off_arity = nargs and nargs > 0 and #exact == 0
  return {
    label = label,
    kind = Kinds.Method,
    filterText = label,
    sortText = (off_arity and "1" or "0") .. label,
    textEdit = { newText = label, range = range },
    labelDetails = { detail = " " .. sig(shown) .. more, description = simple(shown.ret) },
    documentation = { kind = "markdown", value = docs(info, name, overloads) },
    data = { class = info.fq, member = name },
  }
end

local function field_item(info, label, name, field, range, Kinds)
  return {
    label = label,
    kind = Kinds.Field,
    filterText = label,
    textEdit = { newText = label, range = range },
    labelDetails = { description = simple(field.type) },
    documentation = { kind = "markdown", value = docs(info, name, nil, field) },
    data = { class = info.fq, member = name },
  }
end

--- Instance members. style: "." (`.name`), ".-" (`.-field`), "" (bare `name`).
function M.instance(info, style, nargs, range, Kinds)
  local out = {}
  for _, name in ipairs(info.order) do
    local ms = reflect.filter_overloads(info.methods[name], false, nil)
    local field = info.fields[name]
    if field and field.static then
      field = nil
    end
    if style == ".-" then
      if field then
        out[#out + 1] = field_item(info, ".-" .. name, name, field, range, Kinds)
      end
    else
      local prefix = style == "." and "." or ""
      if #ms > 0 then
        out[#out + 1] = method_item(info, prefix .. name, name, ms, nargs, range, Kinds)
      elseif field then
        out[#out + 1] = field_item(info, prefix .. name, name, field, range, Kinds)
      end
    end
  end
  return out
end

--- Static members, labelled `<class_text>/<name>` the way the user typed the class
--- (bare `<name>` when class_text is nil, as in `(. Cls name)`).
function M.static(info, class_text, nargs, range, Kinds)
  local out = {}
  for _, name in ipairs(info.order) do
    local ms = reflect.filter_overloads(info.methods[name], true, nil)
    local field = info.fields[name]
    if field and not field.static then
      field = nil
    end
    local label = class_text and (class_text .. "/" .. name) or name
    if #ms > 0 then
      out[#out + 1] = method_item(info, label, name, ms, nargs, range, Kinds)
    elseif field then
      out[#out + 1] = field_item(info, label, name, field, range, Kinds)
    end
  end
  return out
end

return M
