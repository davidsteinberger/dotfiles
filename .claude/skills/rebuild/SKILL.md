---
name: rebuild
description: Validate this repo's nix-darwin / home-manager config after editing flake.nix or home.nix, surface evaluation errors, and hand the user the switch command to apply it. Use after changing nix-darwin/*.nix or adding a new home.file/xdg.configFile link.
---

# rebuild

Checks that the nix-darwin config still evaluates and builds, without applying it.

## Steps

1. From `~/dotfiles/nix-darwin`, run:

   ```
   darwin-rebuild build --flake ~/dotfiles/nix-darwin --no-out-link
   ```

   This evaluates the flake and builds the system closure. It needs **no sudo**
   and does **not** activate anything. It picks the config matching the current
   hostname (`david` or `dastein1`). `--no-out-link` is required here: unlike
   `switch`, plain `build` otherwise drops a `./result` symlink into whatever
   directory the command was run from.

2. If it fails:
   - Report the failing file and message.
   - Common causes: a `home.file`/`xdg.configFile` entry pointing at a path that
     doesn't exist in the repo; a syntax error; an unfree package without
     `allowUnfree`; a renamed nixpkgs attribute.
   - Fix and re-run step 1.

3. If it succeeds, tell the user it evaluates cleanly and give them the command
   to apply it (they run it, not you):
   - `rebuild` — full system switch (`sudo darwin-rebuild switch --flake ~/dotfiles/nix-darwin`)
   - `hm` — home-manager only, no sudo

## Notes

- `nix flake check` is stricter but slower; use it only if the user asks.
- Never run `darwin-rebuild switch` or `home-manager switch` yourself — those
  activate config and `switch` needs sudo.
