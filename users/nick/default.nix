{ ... }:
{
  imports = [
    ./files.nix
    ./fonts.nix
    ./git.nix
    ./neovim.nix
    ./shell.nix
  ];

  home.stateVersion = "24.11";
}
