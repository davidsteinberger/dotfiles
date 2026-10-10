-- Static type inference over the Clojure syntax tree, resolved through
-- reflection. It only has to be good enough to name a class for completion;
-- when it can't tell, it reports nil and the caller falls back to the generic
-- list. Unlike an analyzer it copes with the half-typed code around the cursor.
local ts = require("conjure_blink.ts")
local reflect = require("conjure_blink.reflect")

local M = {}

local S = "java.lang.String"
local CORE = {
  ["clojure.core/str"] = S, ["clojure.core/pr-str"] = S, ["clojure.core/prn-str"] = S,
  ["clojure.core/print-str"] = S, ["clojure.core/println-str"] = S, ["clojure.core/format"] = S,
  ["clojure.core/subs"] = S, ["clojure.core/slurp"] = S, ["clojure.core/name"] = S,
  ["clojure.core/namespace"] = S,
  ["clojure.core/keyword"] = "clojure.lang.Keyword", ["clojure.core/symbol"] = "clojure.lang.Symbol",
  ["clojure.core/atom"] = "clojure.lang.Atom", ["clojure.core/ref"] = "clojure.lang.Ref",
  ["clojure.core/agent"] = "clojure.lang.Agent",
  ["clojure.core/re-pattern"] = "java.util.regex.Pattern", ["clojure.core/re-matcher"] = "java.util.regex.Matcher",
  ["clojure.java.io/file"] = "java.io.File", ["clojure.java.io/reader"] = "java.io.BufferedReader",
  ["clojure.java.io/writer"] = "java.io.BufferedWriter",
  ["clojure.java.io/input-stream"] = "java.io.BufferedInputStream",
  ["clojure.java.io/output-stream"] = "java.io.BufferedOutputStream",
  ["clojure.java.io/resource"] = "java.net.URL", ["clojure.java.io/as-url"] = "java.net.URL",
}
for _, f in ipairs({ "upper-case", "lower-case", "capitalize", "trim", "triml", "trimr", "trim-newline",
  "join", "replace", "replace-first", "reverse", "escape" }) do
  CORE["clojure.string/" .. f] = S
end

local MAX_DEPTH = 24

local function literal_type(node)
  local t = node:type()
  if t == "str_lit" then
    return S
  elseif t == "num_lit" then
    local txt = ts.text(node)
    if txt:match("N$") then
      return "clojure.lang.BigInt"
    elseif txt:match("M$") then
      return "java.math.BigDecimal"
    elseif txt:find("/") then
      return "clojure.lang.Ratio"
    elseif txt:match("^[-+]?%d+$") or txt:match("^[-+]?0[xX]") or txt:match("^[-+]?%d+[rR]") then
      return "java.lang.Long"
    end
    return "java.lang.Double"
  elseif t == "char_lit" then
    return "java.lang.Character"
  elseif t == "kwd_lit" then
    return "clojure.lang.Keyword"
  elseif t == "bool_lit" then
    return "java.lang.Boolean"
  elseif t == "regex_lit" then
    return "java.util.regex.Pattern"
  elseif t == "vec_lit" then
    return "clojure.lang.PersistentVector"
  elseif t == "map_lit" then
    return "clojure.lang.PersistentArrayMap"
  elseif t == "set_lit" then
    return "clojure.lang.PersistentHashSet"
  end
  return nil
end

--- A ^Hint symbol -> fq class (primitives boxed).
local function hint_class(name, ctx, cb)
  if reflect.BOXED[name] then
    return cb(reflect.BOXED[name])
  end
  reflect.resolve_class(name, ctx, cb)
end

local infer

local function fq_fn(name, ctx)
  local ns, base = name:match("^(.-)/(.+)$")
  if not ns then
    return "clojure.core/" .. name
  end
  return (ctx.aliases[ns] or ns) .. "/" .. base
end

-- type of calling the non-interop function `name` (core table, then ^Tag metadata)
local function fn_type(name, ctx, cb)
  local full = fq_fn(name, ctx)
  if CORE[full] then
    return cb(CORE[full])
  end
  local ns, base = full:match("^(.-)/(.+)$")
  if ns == "clojure.core" and not name:find("/") then
    return reflect.fn_tag(ctx.ns, name, cb)
  end
  reflect.fn_tag(ns, base, cb)
end

--- Type after applying one threading step to `cur` (may be nil = unknown).
local function step_type(cur, step, ctx, first, depth, cb)
  local t = step:type()
  local name, nargs
  if t == "sym_lit" then
    name, nargs = ts.sym_text(step), 0
  elseif t == "list_lit" then
    name, nargs = ts.head(step), #ts.kids(step) - 1
  else
    return cb(nil)
  end
  if not name then
    return cb(nil)
  end
  if name:sub(1, 2) == ".-" then
    if not (cur and (first or nargs == 0)) then return cb(nil) end
    return reflect.field_type(cur, name:sub(3), false, cb)
  elseif name:sub(1, 1) == "." and name ~= "." and name ~= ".." then
    -- under ->> the value lands last, so it is only the receiver when there are no other args
    if not (cur and (first or nargs == 0)) then return cb(nil) end
    return reflect.call_type(cur, name:sub(2), nargs, false, cb)
  end
  local cls, member = name:match("^(.-)/(.+)$")
  if cls and not ctx.aliases[cls] and cls:match("^[%w_.$]+$") then
    return reflect.resolve_class(ctx.imports[cls] or cls, ctx, function(fq)
      if fq then
        return reflect.call_type(fq, member, nargs + 1, true, cb)
      end
      fn_type(name, ctx, cb)
    end)
  end
  fn_type(name, ctx, cb)
end

local function thread_type(form, upto, ctx, depth, cb)
  local kids = ts.kids(form)
  local head = ts.head(form)
  local first = head == "->" or head == "some->"
  infer(kids[2], ctx, depth + 1, function(cur)
    local i = 3
    local function nextstep(acc)
      local step = kids[i]
      if not step or (upto and step:id() == upto:id()) then
        return cb(acc)
      end
      i = i + 1
      step_type(acc, step, ctx, first, depth, nextstep)
    end
    nextstep(cur)
  end)
end
M.thread_type = thread_type

local function dot_dot_type(form, upto, ctx, depth, cb)
  local kids = ts.kids(form)
  infer(kids[2], ctx, depth + 1, function(cur)
    local i = 3
    local function nextstep(acc)
      local step = kids[i]
      if not step or (upto and step:id() == upto:id()) or not acc then
        return cb(acc)
      end
      i = i + 1
      local name, nargs
      if step:type() == "sym_lit" then
        name, nargs = ts.sym_text(step), 0
      elseif step:type() == "list_lit" then
        name, nargs = ts.head(step), #ts.kids(step) - 1
      end
      if not name then return cb(nil) end
      if name:sub(1, 1) == "-" then
        return reflect.field_type(acc, name:sub(2), false, nextstep)
      end
      reflect.call_type(acc, name, nargs, false, nextstep)
    end
    nextstep(cur)
  end)
end
M.dot_dot_type = dot_dot_type

local function list_type(node, ctx, depth, cb)
  local hint = ts.meta_hint(node)
  if hint then
    return hint_class(hint, ctx, cb)
  end
  local kids = ts.kids(node)
  local head = kids[1] and ts.sym_text(kids[1])
  if not head then
    return cb(nil)
  end
  local nargs = #kids - 1

  if head:sub(1, 2) == ".-" and #head > 2 then
    return infer(kids[2], ctx, depth + 1, function(cls)
      if not cls then return cb(nil) end
      reflect.field_type(cls, head:sub(3), false, cb)
    end)
  elseif head:sub(1, 1) == "." and #head > 1 and head ~= ".." then
    return infer(kids[2], ctx, depth + 1, function(cls)
      if not cls then return cb(nil) end
      reflect.call_type(cls, head:sub(2), nargs - 1, false, cb)
    end)
  elseif head == "." then
    local member = kids[3]
    if not member then return cb(nil) end
    local mname, margs = nil, nargs - 2
    if member:type() == "list_lit" then
      mname, margs = ts.head(member), #ts.kids(member) - 1
    else
      mname = ts.sym_text(member)
    end
    if not mname then return cb(nil) end
    local target = kids[2]
    local tname = target:type() == "sym_lit" and ts.sym_text(target)
    local function on_target(cls, static)
      if not cls then return cb(nil) end
      reflect.call_type(cls, mname, margs, static, cb)
    end
    if tname and not ts.find_local(target, tname) then
      return reflect.resolve_class(tname, ctx, function(fq)
        if fq then
          return on_target(fq, true)
        end
        infer(target, ctx, depth + 1, function(cls) on_target(cls, false) end)
      end)
    end
    return infer(target, ctx, depth + 1, function(cls) on_target(cls, false) end)
  elseif head == ".." then
    return dot_dot_type(node, nil, ctx, depth, cb)
  elseif head == "->" or head == "some->" or head == "->>" or head == "some->>" then
    return thread_type(node, nil, ctx, depth, cb)
  elseif head == "doto" then
    return infer(kids[2], ctx, depth + 1, cb)
  elseif head == "do" or head == "let" or head == "let*" or head == "when-let" or head == "with-open" then
    return infer(kids[#kids], ctx, depth + 1, cb)
  elseif head == "new" then
    local c = kids[2] and ts.sym_text(kids[2])
    if not c then return cb(nil) end
    return reflect.resolve_class(c, ctx, cb)
  elseif head:sub(-1) == "." and #head > 1 and head:sub(1, 1) ~= "." then
    return reflect.resolve_class(head:sub(1, -2), ctx, cb)
  end

  local cls, member = head:match("^(.-)/(.+)$")
  if cls and not ctx.aliases[cls] and cls:match("^[%w_.$]+$") then
    return reflect.resolve_class(cls, ctx, function(fq)
      if fq then
        return reflect.call_type(fq, member, nargs, true, cb)
      end
      fn_type(head, ctx, cb)
    end)
  end
  fn_type(head, ctx, cb)
end

local function sym_type(node, ctx, depth, cb)
  local hint = ts.meta_hint(node)
  if hint then
    return hint_class(hint, ctx, cb)
  end
  local ns, name = ts.sym(node)
  if not name then return cb(nil) end
  if not ns then
    local b = ts.find_local(node, name)
    if b then
      local khint = ts.meta_hint(b.key)
      if khint then
        return hint_class(khint, ctx, cb)
      end
      if b.init and not b.elem then
        return infer(b.init, ctx, depth + 1, cb)
      end
      return cb(nil)
    end
    return reflect.var_class(ctx.ns, name, cb)
  end
  if not ctx.aliases[ns] then
    return reflect.resolve_class(ns, ctx, function(fq)
      if fq then
        return reflect.field_type(fq, name, true, cb)
      end
      reflect.var_class(ctx.aliases[ns] or ns, name, cb)
    end)
  end
  reflect.var_class(ctx.aliases[ns], name, cb)
end

--- Infers the class of the value `node` evaluates to; cb(fq|nil).
function infer(node, ctx, depth, cb)
  if not node or depth > MAX_DEPTH or ctx.cancelled then
    return cb(nil)
  end
  local t = node:type()
  local lit = literal_type(node)
  if lit then
    return cb(lit)
  elseif t == "sym_lit" then
    return sym_type(node, ctx, depth, cb)
  elseif t == "list_lit" then
    return list_type(node, ctx, depth, cb)
  end
  cb(nil)
end

function M.infer(node, ctx, cb)
  infer(node, ctx, 0, cb)
end

return M
