#!/bin/sh
# Herdr custom keybinding action for pane navigation.
#
# If the focused pane's foreground process is nvim, forward the equivalent
# alt+shift+<LETTER> chord into the pane instead -- nvim's own keymap
# (config/keymaps.lua) then tries `:wincmd` first and only falls back to
# `herdr pane focus` itself if it's already at the edge of its window layout.
# Otherwise, just move Herdr's pane focus directly.
#
# No jq/subshell: a plain glob match on the raw process-info JSON avoids a
# second child-process spawn on the hot path.
#
# Usage: nvim-aware-nav.sh <herdr-direction: left|down|up|right> <graphite-letter: y|h|a|e>
set -eu

dir="$1"
letter="$2"
pane="${HERDR_ACTIVE_PANE_ID:?HERDR_ACTIVE_PANE_ID not set -- run this via a herdr keys.command binding}"

info=$(herdr pane process-info --pane "$pane")

case "$info" in
  *'"name":"nvim"'*) exec herdr pane send-keys "$pane" "alt+shift+$letter" ;;
  *) exec herdr pane focus --pane "$pane" --direction "$dir" ;;
esac
