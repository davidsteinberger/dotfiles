#!/usr/bin/env zsh
# ---------------------------------------------------------------------------
# Standalone test for repo-clean's planner (its one test seam).
#
# Builds a temp tree of real `git init` repos exhibiting each condition and
# asserts on the dry-run plan text — never on internals, never running the
# executor, no network. Dependencies: git, mktemp, zsh (no bats).
#
#   ./repo-clean.test.zsh          # run
# ---------------------------------------------------------------------------

emulate -L zsh
setopt extended_glob

SCRIPT_DIR=${0:A:h}

# Load repo-clean as an autoloaded function from this directory.
fpath=("$SCRIPT_DIR" $fpath)
autoload -Uz repo-clean

# --- isolated git environment ---------------------------------------------
ROOT=$(mktemp -d "${TMPDIR:-/tmp}/repo-clean-test.XXXXXX")
ROOT=${ROOT:A}   # resolve symlinks / // so paths match repo-clean's ${:A} output
trap 'rm -rf "$ROOT"' EXIT

export GIT_CONFIG_GLOBAL="$ROOT/.gitconfig"
export GIT_CONFIG_SYSTEM=/dev/null
cat > "$GIT_CONFIG_GLOBAL" <<'EOF'
[user]
	name = Test
	email = test@example.com
[init]
	defaultBranch = main
[commit]
	gpgsign = false
[gc]
	auto = 0
EOF

g() { git -C "$1" "${@:2}"; }

mkrepo() {  # mkrepo <path>
  mkdir -p "$1"
  git init -q "$1"
}

# --- fixtures -------------------------------------------------------------

# loose: a repo with a chunky loose object -> git gc worth planning
mkrepo "$ROOT/loose"
head -c 200000 /dev/urandom > "$ROOT/loose/blob.bin"
g "$ROOT/loose" add blob.bin
g "$ROOT/loose" commit -qm init

# deps: ignored node_modules (removable) + tracked build/ (must NOT be removed)
mkrepo "$ROOT/deps"
print -r -- 'node_modules/' > "$ROOT/deps/.gitignore"
mkdir -p "$ROOT/deps/node_modules/pkg" "$ROOT/deps/build"
head -c 60000 /dev/urandom > "$ROOT/deps/node_modules/pkg/index.js"
print -r -- 'artifact' > "$ROOT/deps/build/output.txt"
g "$ROOT/deps" add .gitignore build
g "$ROOT/deps" commit -qm init

# nested-deps: a node_modules several levels deep must still be found
mkrepo "$ROOT/nested-deps"
print -r -- 'node_modules/' > "$ROOT/nested-deps/.gitignore"
mkdir -p "$ROOT/nested-deps/packages/a/b/node_modules/dep"
head -c 40000 /dev/urandom > "$ROOT/nested-deps/packages/a/b/node_modules/dep/x.js"
g "$ROOT/nested-deps" add .gitignore
g "$ROOT/nested-deps" commit -qm init

# dirty: a dirty work tree -> excluded from --deep, kept for the default tier
mkrepo "$ROOT/dirty"
print -r -- 'seed' > "$ROOT/dirty/file.txt"
g "$ROOT/dirty" add file.txt
g "$ROOT/dirty" commit -qm init
print -r -- 'uncommitted change' >> "$ROOT/dirty/file.txt"

# clean: a clean work tree -> --deep steps apply
mkrepo "$ROOT/clean"
print -r -- 'seed' > "$ROOT/clean/file.txt"
g "$ROOT/clean" add file.txt
g "$ROOT/clean" commit -qm init

# remoteless: no remote configured -> no prune action
mkrepo "$ROOT/remoteless"
head -c 20000 /dev/urandom > "$ROOT/remoteless/blob.bin"
g "$ROOT/remoteless" add blob.bin
g "$ROOT/remoteless" commit -qm init

# withremote: a remote configured -> prune action planned
mkrepo "$ROOT/withremote"
head -c 20000 /dev/urandom > "$ROOT/withremote/blob.bin"
g "$ROOT/withremote" add blob.bin
g "$ROOT/withremote" commit -qm init
g "$ROOT/withremote" remote add origin "https://example.invalid/x.git"

# outer + nested inner repo -> inner must be dropped as nested, and the dep-dir
# scan must NOT reach into inner even though outer's .gitignore would match
mkrepo "$ROOT/outer"
print -r -- 'node_modules/' > "$ROOT/outer/.gitignore"
head -c 20000 /dev/urandom > "$ROOT/outer/blob.bin"
g "$ROOT/outer" add .gitignore blob.bin
g "$ROOT/outer" commit -qm init
mkrepo "$ROOT/outer/vendor/inner"
head -c 200000 /dev/urandom > "$ROOT/outer/vendor/inner/blob.bin"
mkdir -p "$ROOT/outer/vendor/inner/node_modules/x"
head -c 30000 /dev/urandom > "$ROOT/outer/vendor/inner/node_modules/x/f"
g "$ROOT/outer/vendor/inner" add blob.bin
g "$ROOT/outer/vendor/inner" commit -qm init

# --- assertion helpers ---------------------------------------------------

PASS=0 FAIL=0

# block <output> <repo-abs-path> -> the plan block for that repo (header + indented lines)
block() {
  print -r -- "$1" | awk -v hdr="$2" '
    $0 == hdr        {grab=1; next}
    grab && /^  /    {print; next}
    grab             {grab=0}
  '
}

ok()   { PASS=$((PASS+1)); print -r -- "  ok   - $1"; }
bad()  { FAIL=$((FAIL+1)); print -r -- "  FAIL - $1"; }

assert_contains() {  # <haystack> <needle> <desc>
  if [[ "$1" == *"$2"* ]]; then ok "$3"; else
    bad "$3"; print -r -- "        expected to find: $2"
  fi
}
assert_not_contains() {  # <haystack> <needle> <desc>
  if [[ "$1" != *"$2"* ]]; then ok "$3"; else
    bad "$3"; print -r -- "        expected NOT to find: $2"
  fi
}

# --- tests -------------------------------------------------------------

print -r -- '# discovery + default tier'
out=$(repo-clean "$ROOT")
assert_contains "$out" "$ROOT/loose"        'loose repo is discovered'
assert_contains "$(block "$out" "$ROOT/loose")" 'git gc' 'loose repo plans git gc'
assert_contains "$out" "$ROOT/deps"         'deps repo is discovered'

print -r -- '# nested-repo rule'
assert_contains     "$out" "$ROOT/outer"              'outer repo is discovered'
assert_not_contains "$out" "$ROOT/outer/vendor/inner" 'nested inner repo is dropped'
assert_not_contains "$(block "$out" "$ROOT/outer")" 'node_modules' 'dep-dir scan does not cross into a nested repo'

print -r -- '# dependency/build directory removal'
depblock=$(block "$out" "$ROOT/deps")
assert_contains     "$depblock" 'rm node_modules'  'ignored node_modules planned for removal'
assert_not_contains "$depblock" 'rm build'         'tracked build/ is never planned for removal'
nestblock=$(block "$out" "$ROOT/nested-deps")
assert_contains "$nestblock" 'packages/a/b/node_modules' 'deeply nested node_modules is found'

print -r -- '# remote-tracking branch prune'
assert_contains     "$(block "$out" "$ROOT/withremote")" 'prune remote-tracking' 'repo with a remote plans a prune'
assert_not_contains "$(block "$out" "$ROOT/remoteless")" 'prune remote-tracking' 'repo with no remote plans no prune'

print -r -- '# REPO_CLEAN_EXCLUDE'
out_excl=$(REPO_CLEAN_EXCLUDE="*/deps:*/clean" repo-clean "$ROOT")
assert_not_contains "$out_excl" "$ROOT/deps"  'excluded repo (deps) is dropped'
assert_not_contains "$out_excl" "$ROOT/clean" 'excluded repo (clean) is dropped'
assert_contains     "$out_excl" "$ROOT/loose" 'non-excluded repo (loose) survives'

print -r -- '# --deep tier with dirty guard'
out_deep=$(repo-clean --deep "$ROOT")
cleanblock=$(block "$out_deep" "$ROOT/clean")
assert_contains "$cleanblock" 'git reflog expire' 'clean repo gets --deep reflog expire'
assert_contains "$cleanblock" 'git clean -xdf'    'clean repo gets --deep git clean'
dirtyblock=$(block "$out_deep" "$ROOT/dirty")
assert_contains     "$dirtyblock" 'SKIPPED'        'dirty repo is skipped from --deep steps'
assert_not_contains "$dirtyblock" 'git clean -xdf' 'dirty repo has no --deep git clean'
assert_contains     "$dirtyblock" 'git gc'         'dirty repo still gets the default tier'

print -r -- '# --deep --force-dirty overrides the guard'
out_force=$(repo-clean --deep --force-dirty "$ROOT")
dirtyforced=$(block "$out_force" "$ROOT/dirty")
assert_contains     "$dirtyforced" 'git clean -xdf' 'force-dirty runs --deep on the dirty repo'
assert_not_contains "$dirtyforced" 'SKIPPED'        'force-dirty removes the skip warning'

print -r -- '# dry run is non-destructive'
[[ -f "$ROOT/deps/node_modules/pkg/index.js" ]] && ok 'dry run left node_modules in place' || bad 'dry run deleted node_modules'
[[ -n $(g "$ROOT/dirty" status --porcelain) ]] && ok 'dry run left the dirty work tree untouched' || bad 'dry run altered the dirty work tree'

print -r -- '# grand total + empty-plan omission'
assert_contains "$out" 'would free ~' 'dry run prints a grand total'
out_v=$(repo-clean -v "$ROOT")
# an empty repo with nothing to clean: appears only under -v
mkrepo "$ROOT/pristine"
out2=$(repo-clean "$ROOT")
out2v=$(repo-clean -v "$ROOT")
assert_not_contains "$out2"  "$ROOT/pristine" 'no-op repo omitted by default'
assert_contains     "$out2v" "$ROOT/pristine" 'no-op repo listed under -v'

print -r -- '# help + bad flags + empty tree'
help_out=$(repo-clean --help); assert_contains "$help_out" 'repo-clean [PATH]' '--help prints usage'
bad_out=$(repo-clean --nonsense 2>&1); assert_contains "$bad_out" 'unknown option' 'unknown flag prints error + usage'
empty_dir=$(mktemp -d "${TMPDIR:-/tmp}/repo-clean-empty.XXXXXX")
none_out=$(repo-clean "$empty_dir"); rc=$?
assert_contains "$none_out" 'no git repos found' 'empty tree reports no repos'
(( rc == 0 )) && ok 'empty tree exits successfully' || bad 'empty tree exit status non-zero'
rm -rf "$empty_dir"

# --- summary -----------------------------------------------------------

print -r -- ''
print -r -- "passed: $PASS   failed: $FAIL"
(( FAIL == 0 ))
