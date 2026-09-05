#!/bin/sh
# Installs any herdr plugin listed below that isn't already installed.
# Run automatically via home-manager activation on `hm`/`rebuild`.
set -eu

command -v herdr >/dev/null 2>&1 || exit 0

desired="
lmilojevicc/herdr-tab-rename
"

installed_json="$(herdr plugin list --json 2>/dev/null || true)"

for spec in $desired; do
    [ -n "$spec" ] || continue
    owner="${spec%%/*}"
    repo="${spec#*/}"
    case "$installed_json" in
        *"\"owner\":\"$owner\",\"repo\":\"$repo\""*) continue ;;
    esac
    echo "herdr: installing plugin $spec"
    herdr plugin install "$spec" --yes || echo "herdr: failed to install $spec" >&2
done
