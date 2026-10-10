#!/usr/bin/env bash
# Runs the conjure_blink regression suite against a throwaway JVM nREPL.
#   tests/conjure_blink/run.sh            # all cases
#   tests/conjure_blink/run.sh toepo      # only cases whose name contains "toepo"
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
port=$((20000 + RANDOM % 10000))
work="$(mktemp -d)"
report="$work/report.txt"
trap 'kill "${nrepl_pid:-0}" 2>/dev/null || true; rm -rf "$work"' EXIT

cd "$work"
clojure -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.8.0"} cider/cider-nrepl {:mvn/version "0.63.1"}}}' \
  -M -m nrepl.cmdline --middleware '[cider.nrepl/cider-middleware]' --port "$port" >"$work/nrepl.log" 2>&1 &
nrepl_pid=$!
for _ in $(seq 1 120); do
  grep -q "nREPL server started" "$work/nrepl.log" 2>/dev/null && break
  sleep 0.5
done
grep -q "nREPL server started" "$work/nrepl.log" || { echo "nREPL failed to start"; cat "$work/nrepl.log"; exit 2; }

status=0
CB_PORT="$port" CB_REPORT="$report" CB_FILTER="${1:-}" CB_TESTS="$here" \
  NVIM_APPNAME="${NVIM_APPNAME:-LazyVim}" nvim --headless "$work/scratch.clj" \
  -c "lua dofile(vim.env.CB_TESTS .. '/harness.lua')" >/dev/null 2>&1 || status=$?
cat "$report" 2>/dev/null || echo "no report written (harness crashed)"
exit "$status"
