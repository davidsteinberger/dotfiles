-- Headless test harness for lua/conjure_blink (started by run.sh).
local port = tonumber(vim.env.CB_PORT)
local report_path = vim.env.CB_REPORT
local filter = vim.env.CB_FILTER ~= "" and vim.env.CB_FILTER or nil
local spec = dofile(vim.env.CB_TESTS .. "/cases.lua")

local out, failures, passed = {}, 0, 0
local function log(line)
  out[#out + 1] = line
end
local function write_report(code)
  local f = io.open(report_path, "w")
  f:write(table.concat(out, "\n") .. "\n")
  f:close()
  vim.cmd(code == 0 and "qa!" or ("cquit " .. code))
end

local function wait(timeout, pred)
  return vim.wait(timeout, pred, 20)
end

vim.defer_fn(function()
  local ok, err = xpcall(function()
    local nrepl = require("conjure_blink.nrepl")
    local reflect = require("conjure_blink.reflect")
    vim.bo.filetype = "clojure"
    vim.cmd("ConjureConnect " .. port)
    assert(wait(20000, function()
      local c = nrepl.conn()
      return c and c.describe and c.describe.ops
    end), "could not connect Conjure to nREPL on port " .. port)

    for _, code in ipairs(spec.setup or {}) do
      local done
      nrepl.eval(code, nil, function() done = true end)
      wait(10000, function() return done end)
    end

    local Kinds = require("blink.cmp.types").CompletionItemKind
    vim.cmd("startinsert")

    local function place(code)
      local lines = vim.split(code, "\n", { plain = true })
      local row, col
      for i, l in ipairs(lines) do
        local c = l:find("|", 1, true)
        if c then
          row, col = i, c - 1
          lines[i] = l:sub(1, c - 1) .. l:sub(c + 1)
          break
        end
      end
      assert(row, "no | marker in case")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      vim.api.nvim_win_set_cursor(0, { row, col })
      return row, col, lines[row]
    end

    local function fetch(code)
      local row, col, line = place(code)
      local source = require("conjure_blink").new()
      local result
      source:get_completions({ cursor = { row, col }, line = line }, function(r) result = r end)
      if not wait(10000, function() return result ~= nil end) then
        return nil
      end
      return result.items
    end

    local function fetch_e2e()
      local blink = require("blink.cmp")
      local list = require("blink.cmp.completion.list")
      blink.hide()
      blink.show({ providers = { "conjure" } })
      wait(8000, function() return blink.is_visible() and #(list.items or {}) > 0 end)
      return list.items or {}
    end

    local function labels_of(items)
      local set, all = {}, {}
      for _, it in ipairs(items) do
        set[it.label] = it
        all[#all + 1] = it.label
      end
      return set, all
    end

    for _, case in ipairs(spec.cases) do
      if not filter or case.name:find(filter, 1, true) then
        local problems = {}
        local items
        if case.e2e then
          place(case.code)
          items = fetch_e2e()
        else
          items = fetch(case.code)
        end
        if not items then
          problems[#problems + 1] = "timed out"
        else
          local set, all = labels_of(items)
          local reflected = 0
          for _, it in ipairs(items) do
            if it.data and it.data.class then
              reflected = reflected + 1
              if case.class and it.data.class ~= case.class then
                problems[#problems + 1] = ("item %s is from %s, expected %s"):format(it.label, it.data.class, case.class)
                break
              end
            end
          end
          if case.class and reflected == 0 then
            problems[#problems + 1] = ("no reflected items (expected %s); got %d generic items"):format(case.class, #items)
          end
          if case.generic and reflected > 0 then
            problems[#problems + 1] = "expected the generic fallback but got reflected items"
          end
          for _, l in ipairs(case.has or {}) do
            if not set[l] then
              problems[#problems + 1] = "missing " .. l
            end
          end
          for _, l in ipairs(case.lacks or {}) do
            if set[l] then
              problems[#problems + 1] = "unexpected " .. l
            end
          end
          for l, want in pairs(case.detail or {}) do
            local it = set[l]
            local got = it and it.labelDetails and it.labelDetails.detail or ""
            if not got:find(want, 1, true) then
              problems[#problems + 1] = ("%s signature %q lacks %q"):format(l, got, want)
            end
          end
          if case.first then
            if case.e2e then
              if all[1] ~= case.first then
                problems[#problems + 1] = ("first item is %s, expected %s"):format(tostring(all[1]), case.first)
              end
            end
          end
        end
        if #problems == 0 then
          passed = passed + 1
          log("PASS  " .. case.name)
        else
          failures = failures + 1
          log("FAIL  " .. case.name)
          for _, p in ipairs(problems) do
            log("        - " .. p)
          end
        end
        reflect.reset()
      end
    end
  end, debug.traceback)

  if not ok then
    failures = failures + 1
    log("HARNESS ERROR: " .. tostring(err))
  end
  log(("\n%d passed, %d failed"):format(passed, failures))
  write_report(failures == 0 and 0 or 1)
end, 1500)
