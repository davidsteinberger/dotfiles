-- Works out, from the syntax tree, what the word under the cursor is a member of.
local ts = require("conjure_blink.ts")
local infer = require("conjure_blink.infer")
local reflect = require("conjure_blink.reflect")

local M = {}

local function same(a, b)
  return a ~= nil and b ~= nil and a:id() == b:id()
end

-- Resolves `node` as the receiver of a member access: cb(class, is_static).
-- A bare class name (as in `(. Instant now)`) is a static receiver.
local function receiver(node, ictx, cb)
  if node:type() == "sym_lit" then
    local text = ts.sym_text(node)
    if text and not ts.find_local(node, text) then
      return reflect.resolve_class(text, ictx, function(fq)
        if fq then
          return cb(fq, true)
        end
        infer.infer(node, ictx, function(cls) cb(cls, false) end)
      end)
    end
  end
  infer.infer(node, ictx, function(cls) cb(cls, false) end)
end

--- Returns nil (nothing special) or one of:
---   { mode = "static",   class_text = "Instant" }
---   { mode = "instance", style = "." | ".-" | "", nargs = n|nil, recv = function(ictx, cb(class, static)) }
function M.locate(root, row0, col0, prefix)
  if prefix:find("/", 1, true) and prefix:sub(1, 1) ~= "." then
    return { mode = "static", class_text = prefix:match("^(.*)/") }
  end

  local cur = ts.sym_at(root, row0, col0 - 1)
  if not cur then
    return nil
  end
  local P = cur:parent()
  if not P or P:type() ~= "list_lit" then
    return nil
  end
  local kids = ts.kids(P)
  local GP = P:parent()
  local gkids = GP and GP:type() == "list_lit" and ts.kids(GP) or nil
  local ghead = gkids and ts.head(GP) or nil
  local THREAD = { ["->"] = true, ["some->"] = true }
  -- ->> puts the value last: it is the receiver only for a step with no other args
  local THREAD_LAST = { ["->>"] = true, ["some->>"] = true }

  if prefix:sub(1, 1) == "." and prefix ~= ".." then
    local style = prefix:sub(1, 2) == ".-" and ".-" or "."
    if same(kids[1], cur) then
      -- (.member target args...)
      if ghead and (THREAD[ghead] or (THREAD_LAST[ghead] and #kids == 1)) and not same(gkids[2], P) then
        return {
          mode = "instance", style = style, nargs = #kids - 1,
          recv = function(ictx, cb)
            infer.thread_type(GP, P, ictx, 0, function(cls) cb(cls, false) end)
          end,
        }
      elseif ghead == "doto" and not same(gkids[2], P) then
        return {
          mode = "instance", style = style, nargs = #kids - 1,
          recv = function(ictx, cb)
            infer.infer(gkids[2], ictx, function(cls) cb(cls, false) end)
          end,
        }
      end
      local target = kids[2]
      return {
        mode = "instance", style = style, nargs = math.max(#kids - 2, 0),
        recv = function(ictx, cb)
          if not target then
            return cb(nil)
          end
          infer.infer(target, ictx, function(cls) cb(cls, false) end)
        end,
      }
    end
    -- (-> x .member)
    local head = ts.head(P)
    if (THREAD[head] or THREAD_LAST[head]) and not same(kids[1], cur) and not same(kids[2], cur) then
      return {
        mode = "instance", style = style, nargs = 0,
        recv = function(ictx, cb)
          infer.thread_type(P, cur, ictx, 0, function(cls) cb(cls, false) end)
        end,
      }
    end
    return nil
  end

  -- (. target member) and (.. target step step)
  local head = ts.head(P)
  if head == "." and same(kids[3], cur) and kids[2] then
    return {
      mode = "instance", style = "", nargs = math.max(#kids - 3, 0),
      recv = function(ictx, cb)
        receiver(kids[2], ictx, cb)
      end,
    }
  elseif head == ".." and #kids >= 3 and not same(kids[1], cur) and not same(kids[2], cur) then
    return {
      mode = "instance", style = "", nargs = 0,
      recv = function(ictx, cb)
        infer.dot_dot_type(P, cur, ictx, 0, function(cls) cb(cls, false) end)
      end,
    }
  elseif ghead == ".." and same(kids[1], cur) and #gkids >= 3 and not same(gkids[2], P) then
    return {
      mode = "instance", style = "", nargs = math.max(#kids - 1, 0),
      recv = function(ictx, cb)
        infer.dot_dot_type(GP, P, ictx, 0, function(cls) cb(cls, false) end)
      end,
    }
  end
  return nil
end

M.receiver = receiver

return M
