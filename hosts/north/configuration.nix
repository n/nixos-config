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

  # Disable broken USB4 port 5 to stop endless retry spam.
  boot.initrd.services.udev.rules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{busnum}=="4", ATTR{devnum}=="1", RUN+="/bin/sh -c 'echo 1 > /sys$devpath/4-0:1.0/usb4-port5/disable'"
  '';

  # Host-specific package(s) beyond the shared base set.
  environment.systemPackages = with pkgs; [
    bubblewrap
  ];

  # Force Linux Wi-Fi regulatory domain (country rules for allowed channels/tx power).
  # Added while troubleshooting Wi-Fi 6E / 6 GHz.
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';

  # Shorten dhcpcd stop timeout to avoid 90s stall during shutdown
  # (dhcpcd hangs trying to release the lease after wpa_supplicant is already down).
  systemd.services.dhcpcd.serviceConfig.TimeoutStopSec = 5;

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

  # Enable Fish shell.
  programs.fish.enable = true;

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
}
