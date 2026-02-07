{ ... }:
{
  environment.persistence."/nix/persist" = {
    hideMounts = true;

    directories = [
      "/etc/ssh"
      "/var/cron"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/var/lib/nixos"
      "/var/lib/sbctl"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale"
    ];

    files = [
      "/etc/machine-id"
      "/etc/wpa_supplicant/imperative.conf"
    ];

    users.nick = {
      directories = [
        "code"
        "Downloads"
        "sync"

        ".cache"
        ".config"
        ".local"

        {
          directory = ".ssh";
          mode = "0700";
        }

        {
          directory = ".pki"; # gnome-keyring
          mode = "0700";
        }

        ".claude"
        ".codex"
        ".cursor"
        ".mozilla"
        ".obsidian"
        ".vscode"
      ];

      files = [
        ".bash_history"
        ".claude.json" # Claude code state
      ];
    };
  };
}
