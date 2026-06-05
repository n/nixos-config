{ ... }:
{
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/ssh"
      "/var/cron"
      "/var/log"
      "/var/lib/docker"
      "/var/lib/nixos"
      "/var/lib/sbctl"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.nick = {
      directories = [
        ".ssh"
        "caddy"
        "code"
        "git"
        "prometheus-grafana"
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
