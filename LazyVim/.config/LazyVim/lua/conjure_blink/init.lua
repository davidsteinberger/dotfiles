-- blink.cmp source backed by Conjure's nREPL connection.
--
--   * Java members: the receiver's class is inferred from the syntax tree
--     (type hints, let/fn locals, call chains, ->, doto, ..) and resolved by
--     reflection, so menus list exactly that class's members with signatures.
--   * Everything else: cider-nrepl's `complete` op.
local nrepl = require("conjure_blink.nrepl")
local ts = require("conjure_blink.ts")
local locate = require("conjure_blink.locate")
local reflect = require("conjure_blink.reflect")
local items = require("conjure_blink.items")
local generic = require("conjure_blink.generic")

local M = {}

function M.new()
  return setmetatable({}, { __index = M })
end

function M:enabled()
  if vim.bo.filetype ~= "clojure" then
    return false
  end
  return nrepl.conn() ~= nil
end

function M:get_trigger_characters()
  return { ".", "/", ":" }
end

local function namespace()
  local ok, ns = pcall(function()
    return require("conjure.extract").context()
  end)
  return ok and ns or nil
end

function M:get_completions(ctx, callback)
  local row, col = ctx.cursor[1], ctx.cursor[2]
  local prefix = vim.fn.matchstr(ctx.line:sub(1, col), [[\k*$]])
  local cancelled = false
  local ictx = { cancelled = false }

  local function finish(list, incomplete)
    if cancelled then
      return
    end
    vim.schedule(function()
      if not cancelled then
        callback({ items = list, is_incomplete_forward = incomplete, is_incomplete_backward = incomplete })
      end
    end)
  end
  local function cancel()
    cancelled = true
    ictx.cancelled = true
  end

  if prefix == "" or not nrepl.conn() then
    finish({}, false)
    return cancel
  end

  local Kinds = require("blink.cmp.types").CompletionItemKind
  local range = {
    start = { line = row - 1, character = col - #prefix },
    ["end"] = { line = row - 1, character = col },
  }
  ictx.ns = namespace()

  local function fallback()
    generic.complete(prefix, row, col, ictx.ns, range, Kinds, function(list)
      finish(list, true)
    end)
  end

  local root = ts.root()
  if not root then
    fallback()
    return cancel
  end
  ictx.imports, ictx.aliases = ts.imports(root)
  local spec = locate.locate(root, row - 1, col, prefix)

  if not spec then
    fallback()
  elseif spec.mode == "static" then
    local ct = spec.class_text
    reflect.resolve_class(ct, ictx, function(fq)
      if not fq then
        return fallback()
      end
      reflect.class_info(fq, function(info)
        if not info then
          return fallback()
        end
        finish(items.static(info, ct, nil, range, Kinds), false)
      end)
    end)
  else
    spec.recv(ictx, function(cls, static)
      if not cls then
        return fallback()
      end
      reflect.class_info(cls, function(info)
        if not info then
          return fallback()
        end
        if static then
          finish(items.static(info, nil, nil, range, Kinds), false)
        else
          finish(items.instance(info, spec.style, spec.nargs, range, Kinds), false)
        end
      end)
    end)
  end

  return cancel
end

-- Javadoc first sentence for a reflected member, via the `info` op.
local function resolve_java(item, callback)
  local d = item.data
  nrepl.send({ op = "info", ns = namespace(), class = d.class, member = d.member }, function(msgs)
    local msg = msgs and msgs[1]
    local text
    if msg and type(msg["doc-first-sentence-fragments"]) == "table" then
      local parts = {}
      for _, frag in ipairs(msg["doc-first-sentence-fragments"]) do
        parts[#parts + 1] = (frag.content or ""):gsub("</?pre>", "`")
      end
      text = table.concat(parts)
    end
    if not text or text == "" then
      return callback(item)
    end
    local resolved = vim.deepcopy(item)
    resolved.documentation = {
      kind = "markdown",
      value = item.documentation.value .. "\n\n" .. text .. (msg.javadoc and ("\n\n" .. msg.javadoc) or ""),
    }
    callback(resolved)
  end)
end

function M:resolve(item, callback)
  if item.data and item.data.class then
    return resolve_java(item, callback)
  end
  if item.documentation or not nrepl.has_op("complete-doc") then
    return callback(item)
  end
  nrepl.send({ op = "complete-doc", ns = namespace(), symbol = item.label }, function(msgs)
    local parts = {}
    for _, msg in ipairs(msgs or {}) do
      if msg["completion-doc"] then
        parts[#parts + 1] = msg["completion-doc"]
      end
    end
    if #parts == 0 then
      return callback(item)
    end
    local resolved = vim.deepcopy(item)
    resolved.documentation = { kind = "markdown", value = "```\n" .. table.concat(parts, "\n") .. "\n```" }
    callback(resolved)
  end)
end

return M
