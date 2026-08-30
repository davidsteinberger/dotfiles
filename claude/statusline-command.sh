#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

SESSION_ID=$(echo "$input" | jq -r '.session_id')

CACHE_FILE="/tmp/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5 # seconds

# "// empty" produces no output when rate_limits is absent
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Pick bar color based on context usage
if [ "$PCT" -ge 80 ]; then
  BAR_COLOR="$RED"
elif [ "$PCT" -ge 50 ]; then
  BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))

cache_is_stale() {
  [ ! -f "$CACHE_FILE" ] ||
    # stat -c %Y (Linux) or stat -f %m (macOS) prints the file's last-modified
    # time. The Linux form must run first: on Linux, the macOS form prints a
    # filesystem report to stdout before failing, and that output would be
    # captured by the command substitution and break the arithmetic.
    [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    REMOTE=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
    PR_URL=""
    if [ -n "$BRANCH" ] && command -v gh >/dev/null 2>&1; then
      PR_URL=$(timeout 3 gh pr view --json url -q .url 2>/dev/null)
    fi
    echo "$BRANCH|$STAGED|$MODIFIED|$REMOTE|$PR_URL" >"$CACHE_FILE"
  else
    echo "||||" >"$CACHE_FILE"
  fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED REMOTE PR_URL <"$CACHE_FILE"

# Color a rate-limit percentage like the context bar: green/yellow/red
limit_fmt() {
  local label=$1 pct=${2%.*}
  local color=$GREEN
  [ "$pct" -ge 50 ] && color=$YELLOW
  [ "$pct" -ge 80 ] && color=$RED
  printf '%s%s: %.0f%%%s' "$color" "$label" "$2" "$RESET"
}

GIT_STATUS=""
[ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
[ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"

# OSC 8 hyperlink around $2, pointing at $1. Falls back to plain $2 when $1
# is empty (e.g. no remote).
link() {
  if [ -n "$1" ]; then
    printf '\e]8;;%s\a%s\e]8;;\a' "$1" "$2"
  else
    printf '%s' "$2"
  fi
}

# Dir points at the repo; branch at its open PR if any, else its tree view.
BRANCH_URL="$PR_URL"
[ -z "$BRANCH_URL" ] && [ -n "$REMOTE" ] && BRANCH_URL="$REMOTE/tree/$BRANCH"
DIR_LABEL=$(link "$REMOTE" "${DIR##*/}")
BRANCH_LABEL=$(link "$BRANCH_URL" "$BRANCH")

LIMITS=""
[ -n "$FIVE_H" ] && LIMITS="$(limit_fmt 5h "$FIVE_H")"
[ -n "$WEEK" ] && LIMITS="${LIMITS:+$LIMITS }$(limit_fmt 7d "$WEEK")"

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR_LABEL} | 🌿 ${BRANCH_LABEL} $GIT_STATUS"
COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET}${LIMITS:+ | $LIMITS} | ⏱️ ${MINS}m ${SECS}s"
