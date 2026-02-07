{ ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.prettier.enable = true;
  programs.shfmt.enable = true;

  settings.global.excludes = [
    "**/lazy-lock.json"
    "**/hardware-configuration.nix"
  ];
}
