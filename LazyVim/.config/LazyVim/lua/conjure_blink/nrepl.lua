-- Thin wrapper over Conjure's nREPL connection: fire-and-forget requests with
-- a timeout, always calling back on the main loop, never touching the user's
-- session (no :session => nREPL uses a throwaway one, so *1 etc. stay intact).
local M = {}

function M.conn()
  local ok, state = pcall(require, "conjure.client.clojure.nrepl.state")
  if not ok then
    return nil
  end
  return state.get("conn")
end

function M.has_op(op)
  local conn = M.conn()
  return conn ~= nil
    and conn.describe ~= nil
    and conn.describe.ops ~= nil
    and conn.describe.ops[op] ~= nil
end

--- Sends `msg`; calls cb(list_of_messages) or cb(nil) on error/timeout.
function M.send(msg, cb, timeout_ms)
  local conn = M.conn()
  if not conn then
    return cb(nil)
  end
  local done = false
  local timer = vim.uv.new_timer()
  local function finish(msgs)
    if done then
      return
    end
    done = true
    if timer then
      timer:stop()
      timer:close()
    end
    vim.schedule(function()
      cb(msgs)
    end)
  end
  timer:start(timeout_ms or 4000, 0, function()
    finish(nil)
  end)
  local server = require("conjure.client.clojure.nrepl.server")
  local remote = require("conjure.remote.nrepl")
  server.send(msg, remote["with-all-msgs-fn"](finish))
end

local UNESCAPE = { n = "\n", t = "\t", r = "\r", ['"'] = '"', ["\\"] = "\\" }

--- Decodes the pr-str of a Clojure string ("a\tb") back into plain text.
function M.decode_string(value)
  if type(value) ~= "string" or value:sub(1, 1) ~= '"' then
    return nil
  end
  local inner = value:sub(2, -2)
  return (inner:gsub("\\(.)", function(c)
    return UNESCAPE[c] or c
  end))
end

--- Evaluates `code` in `ns` (nil = user); calls cb(value_string|nil).
function M.eval(code, ns, cb, timeout_ms)
  M.send({ op = "eval", code = code, ns = ns }, function(msgs)
    if not msgs then
      return cb(nil)
    end
    local value
    for _, msg in ipairs(msgs) do
      if msg.value ~= nil then
        value = msg.value
      end
    end
    cb(value)
  end, timeout_ms)
end

return M
