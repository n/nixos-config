{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "north";
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

  # Enable Ollama with ROCm backend.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
  };

  # Force Linux Wi-Fi regulatory domain (country rules for allowed channels/tx power).
  # Added while troubleshooting Wi-Fi 6E / 6 GHz.
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';

  # Wi-Fi configuration.
  networking.wireless = {
    enable = true;
    scanOnLowSignal = false;
    # Network credentials stored in /etc/wpa_supplicant/imperative.conf (persisted).
    allowAuxiliaryImperativeNetworks = true;
  };

  # Windows keeps the motherboard RTC (hardware clock) in local time by default.
  # Set NixOS to interpret RTC as local time too, so time doesn't jump when dual booting.
  time.hardwareClockInLocalTime = true;

  # Enable nix-ld for running unpatched dynamic binaries on NixOS.
  # See: https://github.com/nix-community/nix-ld
  programs.nix-ld.enable = true;

  # Enable graphics.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable ROCm support.
  nixpkgs.config.rocmSupport = true;

  # Enable AMD GPU kernel module.
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Enable PipeWire for audio.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Mount BTRFS data volume at /data.
  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      # Make boot resilient if disks are temporarily absent:
      "x-systemd.automount"
      "nofail"
    ];
  };

  # Enable automatic BTRFS scrubbing.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/data" ];
  };

  # Raise per-user open-file limit (ulimit -n) system-wide to 1,048,576.
  # Added when testing Go app with large number of open sockets.
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
  ];

  # Override hardware-configuration.nix.
  fileSystems."/" = {
    options = [
      "defaults"
      "size=16G"
      "mode=755"
    ];
  };
  swapDevices = lib.mkForce [
    {
      device = "/dev/disk/by-partlabel/SWAP";
      randomEncryption.enable = true;
    }
  ];

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "24.11"; # Did you read the comment?
}
