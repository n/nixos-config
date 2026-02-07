{ ... }:
{
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/cron"
      "/var/log"
      "/var/lib/docker"
      "/var/lib/nixos"
      "/var/lib/sbctl"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
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
