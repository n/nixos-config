# Ensure neovim has LSP/formatter dependencies available outside of dev shells.
{ pkgs, ... }:
let
  # Remove once upstream resolves https://github.com/NixOS/nixpkgs/issues/509480.
  gotoolsWithoutModernize = pkgs.symlinkJoin {
    name = "gotools-without-modernize";
    paths = [ pkgs.gotools ];
    postBuild = ''
      rm -f "$out/bin/modernize"
    '';
  };
in
{
  home.packages =
    with pkgs;
    [
      neovim

      # conform
      gofumpt
      gotoolsWithoutModernize # goimports
      prettier
      ruff
      stylua

      # lsp
      astro-language-server # astro
      basedpyright # basedpyright
      python312
      bash-language-server # bashls
      shellcheck
      shfmt
      gopls # gopls
      go
      lua-language-server # lua_ls
      nixd # nixd
      nixfmt
      tailwindcss-language-server # tailwindcss
      typescript-language-server # ts
      nodejs_24
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      xsel
    ];

  home.shellAliases.vi = "nvim";
}
