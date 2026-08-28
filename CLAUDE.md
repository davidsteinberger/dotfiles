# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles. Each top-level directory holds the config for one tool
(`zsh/`, `git/`, `LazyVim/`, `aerospace/`, ...). The repo is expected to live at
`~/dotfiles`.

## How dotfiles get installed

`nix-darwin` + `home-manager` are the install mechanism (the old GNU Stow
`install.sh` flow is retired). `nix-darwin/flake.nix` and `nix-darwin/home.nix`
are the source of truth.

- Files are linked into place with `config.lib.file.mkOutOfStoreSymlink`, so the
  installed dotfile is a symlink back to this repo. **Editing an already-linked
  file takes effect immediately** — no rebuild needed.
- **Adding a new config file or directory requires a matching entry in
  `nix-darwin/home.nix`** (`home.file."..."` or `xdg.configFile."..."`).
  Creating the file alone does nothing — it won't be linked.
- After changing `home.nix` / `flake.nix` (or adding links), the user runs one
  of these — you don't run them:
  - `rebuild` → `sudo darwin-rebuild switch --flake ~/dotfiles/nix-darwin` (system + home)
  - `hm` → `home-manager switch` only (no sudo)
  - `update` → `nix flake update`
- Two host configs share one `home.nix`: `david` (`/Users/david`) and `dastein1`
  (user `davidsteinberger`, `/Users/davidsteinberger`). Don't hardcode a home
  path or username — use `config.home.homeDirectory` / `config.home.username`.

## This repo edits live agent + shell config

`home.nix` links several directories here straight into active config locations,
so changes are not sandboxed to the repo:

- `claude/settings.json`, `claude/keybindings.json`, `claude/hooks/`,
  `claude/skills/` → `~/.claude/...`
- `agents/skills/` → `~/.agents/skills`
- `opencode/.config/opencode/` → `~/.config/opencode`
- `zsh/` files → `~/.z*`; `.zshrc` is inlined via `programs.zsh.initContent`

`claude/hooks/herdr-agent-state.sh` is managed by herdr — don't edit it; add
sibling hook files instead.

## Conventions

- Format Nix with `alejandra` (matches the multi-line function-arg style in
  `flake.nix` / `home.nix`).
- Commit only when asked. Commits go directly to `master`; keep messages short
  (existing history is terse, e.g. "update config").
- Never commit secrets. Local/gitignored: `.env`, `zsh/.zlocal.zsh`,
  `zsh/.zfuncs/secret`. GPG/YubiKey + `pass` handle credentials.
- Apple-silicon only (`aarch64-darwin`). No tests, no CI.
