{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "home";
  networking.firewall.enable = false;
  time.timeZone = "America/New_York";

  # Lanzaboote.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Use systemd-based initrd (stage-1); needed for common TPM2/LUKS auto-unlock setups (systemd-cryptenroll/cryptsetup units).
  boot.initrd.systemd.enable = true;

  # Allow NixOS to write UEFI firmware (NVRAM) boot entries during installs/rebuilds
  # (e.g., create/update the “NixOS” entry in the BIOS boot menu / sometimes boot order).
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Base system packages.
  environment.systemPackages = with pkgs; [
    btrfs-progs
    ghostty.terminfo
    lm_sensors
    sbctl
    tmux
    vim
  ];
  environment.variables = {
    EDITOR = "vim";
  };

  # Enable cron.
  services.cron.enable = true;

  # Enable OpenSSH.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  # Required for ShellFish shell integration.
  services.openssh.extraConfig = ''
    AcceptEnv LANG LC_*
  '';

  # Enable Tailscale.
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-routes" ];
  };

  # Enable Docker and Podman.
  virtualisation.docker.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
  };

  # Persist important /etc files.
  environment.etc."machine-id".source = "/nix/persist/etc/machine-id";
  environment.etc."ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
  environment.etc."ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
  environment.etc."ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
  environment.etc."ssh/ssh_host_ed25519_key.pub".source =
    "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";

  # Override hardware-configuration.nix.
  fileSystems."/" = {
    options = [
      "defaults"
      "size=8G"
      "mode=755"
    ];
  };
  swapDevices = lib.mkForce [
    {
      device = "/dev/disk/by-partlabel/swap";
      randomEncryption.enable = true;
    }
  ];

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "24.11"; # Did you read the comment?
}
