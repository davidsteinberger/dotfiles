-- Reflection queries against the connected JVM (via a throwaway nREPL session).
-- Nothing of the user's code is evaluated. Successful lookups are cached;
-- failures are not, so a lookup that raced the ns load is retried.
local nrepl = require("conjure_blink.nrepl")

local M = {}

local cache = {}

function M.reset()
  cache = {}
end

local BOXED = {
  long = "java.lang.Long", int = "java.lang.Integer", short = "java.lang.Short",
  byte = "java.lang.Byte", double = "java.lang.Double", float = "java.lang.Float",
  boolean = "java.lang.Boolean", char = "java.lang.Character",
}
M.BOXED = BOXED

--- Normalises a reflected return type to something usable as a hint, or nil.
function M.usable(name)
  if not name or name == "" or name == "void" or name:sub(1, 1) == "[" then
    return nil
  end
  if name == "java.lang.Object" then
    return nil
  end
  return BOXED[name] or name
end

local function cached(key, fetch, cb)
  if cache[key] ~= nil then
    return cb(cache[key])
  end
  fetch(function(result)
    if result ~= nil then
      cache[key] = result
    end
    cb(result)
  end)
end

local function lua_str(s)
  return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

local function fill(template, vars)
  return (template:gsub("@(%u+)@", function(k)
    return vars[k]
  end))
end

--- Resolves a (possibly short) class name to its fully qualified name.
function M.resolve_class(name, ctx, cb)
  local cands = {}
  if ctx.imports and ctx.imports[name] then
    cands[#cands + 1] = ctx.imports[name]
  end
  if name:find("%.") then
    cands[#cands + 1] = name
  else
    cands[#cands + 1] = "java.lang." .. name
  end
  local quoted = {}
  for _, c in ipairs(cands) do
    quoted[#quoted + 1] = lua_str(c)
  end
  local code = fill(
    [[(or (some (fn [n] (try (.getName (clojure.lang.RT/classForName n)) (catch Throwable _ nil))) [@CANDS@])
          (try (let [r (ns-resolve (or (find-ns '@NS@) *ns*) '@NAME@)] (when (class? r) (.getName ^Class r))) (catch Throwable _ nil)))]],
    { CANDS = table.concat(quoted, " "), NS = ctx.ns or "user", NAME = name }
  )
  cached("class|" .. (ctx.ns or "") .. "|" .. name .. "|" .. table.concat(cands, ","), function(done)
    nrepl.eval(code, nil, function(v)
      done(nrepl.decode_string(v))
    end)
  end, cb)
end

local CLASS_INFO = [[
(try
  (let [c (clojure.lang.RT/classForName "@CLASS@")
        st? (fn [m] (java.lang.reflect.Modifier/isStatic (.getModifiers ^java.lang.reflect.Member m)))
        names (fn [ks] (apply str (interpose "," (map (fn [^Class k] (.getName k)) ks))))
        ms (->> (concat (.getMethods c) (when (.isInterface c) (.getMethods Object)))
                (remove (fn [^java.lang.reflect.Method m] (.isBridge m)))
                (map (fn [^java.lang.reflect.Method m]
                       (str "M\t" (.getName m) "\t" (if (st? m) 1 0) "\t" (.getName (.getReturnType m)) "\t" (names (.getParameterTypes m))))))
        fs (->> (.getFields c)
                (map (fn [^java.lang.reflect.Field f]
                       (str "F\t" (.getName f) "\t" (if (st? f) 1 0) "\t" (.getName (.getType f))))))
        cs (->> (.getConstructors c)
                (map (fn [^java.lang.reflect.Constructor k] (str "C\t\t0\t\t" (names (.getParameterTypes k))))))]
    (apply str (interpose "\n" (concat [(str "K\t" (if (.isInterface c) "interface" "class"))] ms fs cs))))
  (catch Throwable _ nil))]]

--- Public members of a class:
--- { fq, interface, methods = {name -> {{static, ret, params}}}, fields = {name -> {static, type}},
---   ctors = {{params}}, order = {names in declaration order} }
function M.class_info(fq, cb)
  cached("info|" .. fq, function(done)
    nrepl.eval(fill(CLASS_INFO, { CLASS = fq }), nil, function(v)
      local text = nrepl.decode_string(v)
      if not text then
        return done(nil)
      end
      local info = { fq = fq, methods = {}, fields = {}, ctors = {}, order = {}, seen = {} }
      for line in text:gmatch("[^\n]+") do
        local f = vim.split(line, "\t", { plain = true })
        local function note(name)
          if not info.seen[name] then
            info.seen[name] = true
            info.order[#info.order + 1] = name
          end
        end
        if f[1] == "K" then
          info.interface = f[2] == "interface"
        elseif f[1] == "M" then
          note(f[2])
          info.methods[f[2]] = info.methods[f[2]] or {}
          local params = f[5] and f[5] ~= "" and vim.split(f[5], ",", { plain = true }) or {}
          table.insert(info.methods[f[2]], { static = f[3] == "1", ret = f[4], params = params })
        elseif f[1] == "F" then
          note(f[2])
          info.fields[f[2]] = { static = f[3] == "1", type = f[4] }
        elseif f[1] == "C" then
          local params = f[5] and f[5] ~= "" and vim.split(f[5], ",", { plain = true }) or {}
          table.insert(info.ctors, { params = params })
        end
      end
      done(info)
    end)
  end, cb)
end

local function filter(list, static, nargs)
  local exact, same_kind = {}, {}
  for _, m in ipairs(list or {}) do
    if m.static == static then
      same_kind[#same_kind + 1] = m
      if nargs == nil or #m.params == nargs then
        exact[#exact + 1] = m
      end
    end
  end
  return #exact > 0 and exact or same_kind
end
M.filter_overloads = filter

local function unique(types)
  local set, n, last = {}, 0, nil
  for _, t in ipairs(types) do
    if not set[t] then
      set[t] = true
      n = n + 1
      last = t
    end
  end
  return n == 1 and last or nil
end

--- Type of `(.name <cls> args...)` / `(Cls/name args...)`: cb(fq|nil).
function M.call_type(cls, name, nargs, static, cb)
  M.class_info(cls, function(info)
    if not info then
      return cb(nil)
    end
    local overloads = filter(info.methods[name], static, nargs)
    if #overloads > 0 then
      local rets = {}
      for _, m in ipairs(overloads) do
        rets[#rets + 1] = m.ret
      end
      return cb(M.usable(unique(rets)))
    end
    local field = info.fields[name]
    if field and field.static == static then
      return cb(M.usable(field.type))
    end
    cb(nil)
  end)
end

--- Type of field access `(.-name obj)` / `Cls/NAME`: cb(fq|nil).
function M.field_type(cls, name, static, cb)
  M.class_info(cls, function(info)
    local field = info and info.fields[name]
    cb(field and field.static == static and M.usable(field.type) or nil)
  end)
end

--- Class of the value a var currently holds (non-fn values only).
function M.var_class(ns, sym, cb)
  local code = fill(
    [[(try (let [v (ns-resolve (or (find-ns '@NS@) *ns*) '@SYM@)]
             (when (var? v) (let [x (deref v)] (when (and (some? x) (not (fn? x))) (.getName (class x))))))
           (catch Throwable _ nil))]],
    { NS = ns or "user", SYM = sym }
  )
  cached("var|" .. (ns or "") .. "|" .. sym, function(done)
    nrepl.eval(code, nil, function(v)
      done(nrepl.decode_string(v))
    end)
  end, cb)
end

--- Declared return type (^Tag on the var or an arglist) of a function var.
function M.fn_tag(ns, sym, cb)
  local code = fill(
    [[(try (let [v (ns-resolve (or (find-ns '@NS@) *ns*) '@SYM@)]
             (when (var? v)
               (let [m (meta v)
                     t (or (:tag m) (some (fn [al] (:tag (meta al))) (:arglists m)))
                     c (cond (class? t) t
                             (symbol? t) (let [r (ns-resolve (.ns ^clojure.lang.Var v) t)] (when (class? r) r))
                             (string? t) (try (clojure.lang.RT/classForName t) (catch Throwable _ nil)))]
                 (when c (.getName ^Class c)))))
           (catch Throwable _ nil))]],
    { NS = ns or "user", SYM = sym }
  )
  cached("tag|" .. (ns or "") .. "|" .. sym, function(done)
    nrepl.eval(code, nil, function(v)
      done(nrepl.decode_string(v))
    end)
  end, cb)
end

return M
