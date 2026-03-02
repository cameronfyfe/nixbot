# OpenClaw Setup Plan (NixOS)

Date: 2026-03-01
Host: `nixos` (`x86_64-linux`)

## Documentation Reviewed
- https://github.com/openclaw/nix-openclaw
- `docs/golden-paths.md` (Linux path)
- `templates/agent-first/flake.nix`
- Home Manager module options under `nix/modules/home-manager/openclaw`

## Goal
Set up OpenClaw on this NixOS host using the upstream Home Manager module (recommended Linux path), managed from `/etc/nixos` flake.

## Execution Status
- [x] Added `home-manager` and `nix-openclaw` flake inputs in `/etc/nixos/flake.nix`.
- [x] Enabled `home-manager.nixosModules.home-manager` and passed `nix-openclaw` via `specialArgs`.
- [x] Added OpenClaw overlay so `pkgs.openclaw` is available.
- [x] Configured `home-manager` for `nixbot` with `nix-openclaw.homeManagerModules.openclaw`.
- [x] Configured default OpenClaw Linux instance (systemd user service) with placeholder gateway/Telegram values.
- [x] Created required documents (`AGENTS.md`, `SOUL.md`, `TOOLS.md`) under `/etc/nixos/openclaw/documents`.
- [x] Created placeholder Telegram token file at `/etc/nixos/openclaw/secrets/telegram-bot-token`.
- [x] Updated `flake.lock` and validated evaluation.
- [x] Built full system successfully with `nixos-rebuild build --flake .#nixos`.
- [ ] Apply with root privileges: `sudo nixos-rebuild switch --flake /etc/nixos#nixos --accept-flake-config`.

## Web-First Mode (Applied In Config)
- Gateway bind mode set to LAN (`gateway.bind = "lan"`).
- Control UI LAN origins configured:
  - `http://127.0.0.1:18789`
  - `http://localhost:18789`
  - `http://nixos:18789`
  - `http://nixos.local:18789`
  - `http://192.168.1.212:18789`
- `gateway.controlUi.allowInsecureAuth = true` enabled for plain-HTTP LAN browser access.
- NixOS firewall now allows TCP port `18789`.
- Telegram channel is present but disabled for now (`channels.telegram.enabled = false`) so web chat can be validated first.

## LAN Web Access Steps
1. Apply config: `sudo nixos-rebuild switch --flake /etc/nixos#nixos --accept-flake-config`
2. Open from LAN: `http://192.168.1.212:18789/`
3. Paste gateway token in Control UI settings (currently from `gateway.auth.token` in `/etc/nixos/configuration.nix`).
4. Approve browser device if prompted:
   - `openclaw devices list`
   - `openclaw devices approve <requestId>`

## Later: Enable Telegram
1. Replace `/etc/nixos/openclaw/secrets/telegram-bot-token` with real bot token.
2. Replace `channels.telegram.allowFrom = [ 123456789 ];` with your user/group IDs.
3. Set `channels.telegram.enabled = true`.
4. Re-apply: `sudo nixos-rebuild switch --flake /etc/nixos#nixos --accept-flake-config`

## Inputs Still Needed From You (for full production use)
- Telegram bot token (`@BotFather`)
- Telegram allow list IDs (`@userinfobot`; users/groups)
- Final gateway auth token value (replace placeholder)
- OpenAI Codex OAuth profile for OpenClaw (`openclaw models auth login --provider openai-codex`)

## Current Placeholder Values to Replace
- `/etc/nixos/configuration.nix`:
  - `gateway.auth.token = "REPLACE_WITH_LONG_RANDOM_GATEWAY_TOKEN";`
  - `channels.telegram.allowFrom = [ 123456789 ];`
- `/etc/nixos/openclaw/secrets/telegram-bot-token`:
  - `REPLACE_WITH_TELEGRAM_BOT_TOKEN`

## Validation Targets
- `nix flake check` (optional/heavier)
- `nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`
- After rebuild:
  - `systemctl --user status openclaw-gateway`
  - `journalctl --user -u openclaw-gateway -n 100 --no-pager`
