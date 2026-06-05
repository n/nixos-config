{ config, ... }:
let
  # Create a symlink to a file in the dotfiles directory.
  # Use this to enable edit in place. Otherwise, files are read-only.
  mkSymlink =
    relPath:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/sync/n/nixos-config/users/nick/${relPath}";
in
{
  xdg.configFile = {
    "direnv/direnvrc".source = dotfiles/.config/direnv/direnvrc;
    "fd/ignore".source = dotfiles/.config/fd/ignore;
    "i3/config".source = dotfiles/.config/i3/config;
    "i3status/config".source = dotfiles/.config/i3status/config;
    "i3status/i3status.sh".source = dotfiles/.config/i3status/i3status.sh;
    "sway/config".source = dotfiles/.config/sway/config;

    "ghostty/config".source = mkSymlink "dotfiles/.config/ghostty/config";
    "niri/config.kdl".source = mkSymlink "dotfiles/.config/niri/config.kdl";
    "waybar".source = mkSymlink "dotfiles/.config/waybar/";
    "mako/config".source = mkSymlink "dotfiles/.config/mako/config";
    "fuzzel/fuzzel.ini".source = mkSymlink "dotfiles/.config/fuzzel/fuzzel.ini";
  };

  home.file = {
    ".background-image".source = dotfiles/.background-image;
    ".gitignore_global".source = dotfiles/.gitignore_global;
    ".rgignore".source = dotfiles/.rgignore;
    ".tmux.conf".source = dotfiles/.tmux.conf;
    ".vimrc".source = dotfiles/.vimrc;
  };
}
