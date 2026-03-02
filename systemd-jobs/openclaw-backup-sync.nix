{ ... }:
{
  # Daily sanitized backup push of ~/.openclaw into private repo.
  systemd.services.openclaw-backup-sync = {
    description = "Sync and push sanitized OpenClaw backup";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "nixbot";
      Group = "users";
      WorkingDirectory = "/home/nixbot/openclaw-backup";
      ExecStart = "/home/nixbot/openclaw-backup/scripts/auto-backup.sh";
    };
  };

  systemd.timers.openclaw-backup-sync = {
    description = "Run OpenClaw backup sync daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 06:15:00";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}
