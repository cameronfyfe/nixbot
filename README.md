# nixbot NixOS Configuration

Declarative NixOS + Home Manager configuration for the `nixbot` host, including OpenClaw setup.

## What’s in this repo

- `configuration.nix` — main system and Home Manager config
- `flake.nix` / `flake.lock` — flake entrypoint and lockfile
- `hardware-configuration.nix` — hardware-specific config
- `openclaw/documents/` — assistant documents (`AGENTS.md`, `SOUL.md`, `TOOLS.md`)
- `pkgs/` — custom package overlays/derivations (e.g. `codex.nix`)
- `scripts/` — helper scripts

## Usage

From `/etc/nixos`:

```bash
# Validate/build only
nixos-rebuild build

# Apply configuration
sudo nixos-rebuild switch
```

## Notes

- Secrets are intentionally excluded from git via `.gitignore` (`openclaw/secrets/*`).
- This repo is intended to be the source of truth for system config.

## GitHub

Remote: `git@github.com:cameronfyfe/nixbot.git`
