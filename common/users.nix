let
  keys = import ./keys.nix;
in
{
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
  users.users.root.hashedPasswordFile = "/nix/persist/secrets/root-hashed-password";
  users.users.nick = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = builtins.attrValues keys.nick;
    hashedPasswordFile = "/nix/persist/secrets/nick-hashed-password";
    extraGroups = [
      "audio"
      "docker"
      "wheel"
    ];
  };
}
