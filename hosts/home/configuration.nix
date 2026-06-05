{
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "home";

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
}
