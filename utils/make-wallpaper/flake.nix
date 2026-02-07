{
  inputs = {
    nixos-artwork.url = "github:NixOS/nixos-artwork";
    nixos-artwork.flake = false; # Fetch as plain source, not as a flake
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nixos-artwork,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "nixos-artwork";

          packages = with pkgs; [
            imagemagick

            (writeShellScriptBin "make-wallpaper" ''
              set -eu

              root=$(git rev-parse --show-toplevel)
              output="''${1:-$root/users/nick/dotfiles/.background-image}"

              wallpaper="${nixos-artwork}/wallpapers/nix-wallpaper-binary-black.png"
              color=#$(magick $wallpaper -format '%[hex:p{1,1}]' info:)

              magick "$wallpaper" \
                -resize 1440x1440^ \
                -background "$color" \
                -gravity center \
                -extent 3440x1440 \
                "$output"
            '')
          ];

          shellHook = ''
            cat <<'EOF'
Usage: make-wallpaper [output-path]
EOF
          '';
        };
      }
    );
}
