# Shared configuration for all physical NixOS hosts.
# Host-specific bits (hostname, filesystem sizes, swap, desktop/hardware) live in
# each host's own configuration.nix.
{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./users.nix
  ];

  networking.firewall.enable = false;
  time.timeZone = "America/New_York";

  # Lanzaboote.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Use systemd-based initrd (stage-1); needed for common TPM2/LUKS auto-unlock setups (systemd-cryptenroll/cryptsetup units).
  boot.initrd.systemd.enable = true;

  # Allow NixOS to write UEFI firmware (NVRAM) boot entries during installs/rebuilds
  # (e.g., create/update the "NixOS" entry in the BIOS boot menu / sometimes boot order).
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
  environment.localBinInPath = true;

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

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "24.11"; # Did you read the comment?
}
