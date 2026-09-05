#!/bin/sh
# Installs any herdr plugin listed below that isn't already installed.
# Run automatically via home-manager activation on `hm`/`rebuild`.
set -eu

# home-manager activation scripts run with a minimal, hermetic PATH that
# excludes Homebrew and even /usr/bin, so herdr (installed via brew) and
# tools it shells out to (e.g. git) won't be found otherwise.
PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

if ! command -v herdr >/dev/null 2>&1; then
    echo "herdr: skipping plugin install, herdr not found (expected at /opt/homebrew/bin)" >&2
    exit 0
fi

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
