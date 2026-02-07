{ lib, pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      # Sway and related packages
      i3status
      kitty # for i3
      rofi
      wl-clipboard
      mako

      # Graphical applications
      code-cursor
      firefox
      ghostty
      gnome-font-viewer
      gnome-software
      nautilus
      obsidian
      pavucontrol
      ungoogled-chromium
      vscode

      # TUIs
      claude-code
    ];
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "cursor"
      "obsidian"
      "steam"
      "steam-unwrapped"
      "vscode"
      "claude-code"
    ];

  # Enable flatpak.
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Fix Chromium warnings.
  # The name org.freedesktop.UPower was not provided by any .service files...
  services.upower.enable = true;

  # Enable the GNOME-keyring secrets vault.
  services.gnome.gnome-keyring.enable = true;

  # Configure greeter.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.autoSuspend = false;

  # dconf is required for certain GNOME settings.
  programs.dconf.enable = true;

  # Blank login screen instead of autoSuspend.
  programs.dconf.profiles.gdm.databases = [
    {
      settings = {
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = lib.gvariant.mkString "blank";
          sleep-inactive-ac-timeout = lib.gvariant.mkInt32 300;
        };
      };
    }
  ]
  ++ [ "${pkgs.gdm}/share/gdm/greeter-dconf-defaults" ];

  # Add/override keys in the default “user” profile.
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    }
  ];

  # Enable Steam.
  programs.steam.enable = true;

  # Enable Sway.
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
  };
}
