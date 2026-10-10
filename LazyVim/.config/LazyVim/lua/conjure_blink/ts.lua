-- Treesitter helpers for the Clojure parser: structure instead of regexes.
local M = {}

local SKIP = { comment = true, dis_expr = true, meta_lit = true }

function M.root()
  local ok, parser = pcall(vim.treesitter.get_parser, 0, "clojure")
  if not ok or not parser then
    return nil
  end
  local trees = parser:parse()
  return trees[1] and trees[1]:root() or nil
end

function M.text(node)
  return vim.treesitter.get_node_text(node, 0)
end

--- Significant named children (no comments, #_ discards or ^metadata).
function M.kids(node)
  local out = {}
  for child in node:iter_children() do
    if child:named() and not SKIP[child:type()] then
      out[#out + 1] = child
    end
  end
  return out
end

--- ns, name of a sym_lit (metadata excluded).
function M.sym(node)
  local ns, name
  for c in node:iter_children() do
    if c:type() == "sym_ns" then
      ns = M.text(c)
    elseif c:type() == "sym_name" then
      name = M.text(c)
    end
  end
  return ns, name
end

function M.sym_text(node)
  if not node or node:type() ~= "sym_lit" then
    return nil
  end
  local ns, name = M.sym(node)
  if not name then
    return nil
  end
  return ns and (ns .. "/" .. name) or name
end

--- Text of the type hint (^Tag) attached to a form, if it is a plain symbol/string.
function M.meta_hint(node)
  for child in node:iter_children() do
    if child:type() == "meta_lit" then
      for c in child:iter_children() do
        if c:named() then
          local t = c:type()
          if t == "sym_lit" then
            return M.sym_text(c)
          elseif t == "str_lit" then
            return M.text(c):sub(2, -2)
          end
          return nil
        end
      end
    end
  end
end

--- Symbol text of a list's head, or nil.
function M.head(list)
  local k = M.kids(list)[1]
  return k and M.sym_text(k) or nil
end

local function le(r1, c1, r2, c2)
  return r1 < r2 or (r1 == r2 and c1 <= c2)
end

local function ends_before(a, b)
  local _, _, er, ec = a:range()
  local sr, sc = b:range()
  return le(er, ec, sr, sc)
end

local function contains(outer, inner)
  local osr, osc, oer, oec = outer:range()
  local isr, isc, ier, iec = inner:range()
  return le(osr, osc, isr, isc) and le(ier, iec, oer, oec)
end
M.contains = contains

local BIND = {
  let = true, ["let*"] = true, loop = true, ["loop*"] = true,
  ["when-let"] = true, ["if-let"] = true, ["when-some"] = true, ["if-some"] = true,
  ["with-open"] = true, doseq = true, ["for"] = true,
}
local FN = { fn = true, ["fn*"] = true, defn = true, ["defn-"] = true, defmacro = true, defmethod = true }

--- Finds the binding of local `name` visible at `node`.
--- Returns { key = sym_node, init = node|nil, elem = bool } or nil.
function M.find_local(node, name)
  local p = node:parent()
  while p do
    if p:type() == "list_lit" then
      local kids = M.kids(p)
      local h = kids[1] and M.sym_text(kids[1])
      if h and BIND[h] then
        local vec
        for i = 2, #kids do
          if kids[i]:type() == "vec_lit" then
            vec = kids[i]
            break
          end
        end
        if vec then
          local items, found = M.kids(vec), nil
          for i = 1, #items - 1, 2 do
            local k, v = items[i], items[i + 1]
            if ends_before(v, node) and k:type() == "sym_lit" and M.sym_text(k) == name then
              found = { key = k, init = v, elem = (h == "doseq" or h == "for") }
            end
          end
          if found then
            return found
          end
        end
      elseif h and FN[h] then
        local params
        for i = 2, #kids do
          local c = kids[i]
          if c:type() == "vec_lit" then
            params = params or c
          elseif c:type() == "list_lit" and contains(c, node) then
            local first = M.kids(c)[1]
            if first and first:type() == "vec_lit" then
              params = first
            end
          end
        end
        if params then
          for _, s in ipairs(M.kids(params)) do
            if s:type() == "sym_lit" and M.sym_text(s) == name then
              return { key = s }
            end
          end
        end
      end
    end
    p = p:parent()
  end
  return nil
end

--- Short class name -> fq name (from ns :import / (import ...)), alias -> ns (from :require).
function M.imports(root)
  local imports, aliases = {}, {}

  local function add_spec(spec)
    local t = spec:type()
    if t == "quoting_lit" then
      for _, c in ipairs(M.kids(spec)) do
        add_spec(c)
      end
    elseif t == "vec_lit" or t == "list_lit" then
      local k = M.kids(spec)
      local pkg = k[1] and M.sym_text(k[1])
      if pkg then
        for i = 2, #k do
          local cname = M.sym_text(k[i])
          if cname then
            imports[cname] = pkg .. "." .. cname
          end
        end
      end
    elseif t == "sym_lit" then
      local fq = M.sym_text(spec)
      local short = fq and fq:match("([^.]+)$")
      if short and fq:find("%.") then
        imports[short] = fq
      end
    end
  end

  local function add_require(spec)
    if spec:type() ~= "vec_lit" then
      return
    end
    local k = M.kids(spec)
    local ns = k[1] and M.sym_text(k[1])
    for i = 2, #k - 1 do
      if k[i]:type() == "kwd_lit" and M.text(k[i]) == ":as" and k[i + 1]:type() == "sym_lit" then
        aliases[M.sym_text(k[i + 1])] = ns
      end
    end
  end

  for _, form in ipairs(M.kids(root)) do
    if form:type() == "list_lit" then
      local kids = M.kids(form)
      local h = kids[1] and M.sym_text(kids[1])
      if h == "ns" then
        for i = 2, #kids do
          if kids[i]:type() == "list_lit" then
            local sub = M.kids(kids[i])
            local kw = sub[1] and sub[1]:type() == "kwd_lit" and M.text(sub[1])
            for j = 2, #sub do
              if kw == ":import" then
                add_spec(sub[j])
              elseif kw == ":require" then
                add_require(sub[j])
              end
            end
          end
        end
      elseif h == "import" then
        for i = 2, #kids do
          add_spec(kids[i])
        end
      end
    end
  end
  return imports, aliases
end

--- The sym_lit under the cursor whose last character is at (row0, col0).
function M.sym_at(root, row0, col0)
  local node = root:named_descendant_for_range(row0, col0, row0, col0)
  while node do
    local t = node:type()
    if t == "sym_lit" then
      return node
    elseif t == "sym_name" or t == "sym_ns" then
      node = node:parent()
    else
      return nil
    end
  end
  return nil
end

return M
