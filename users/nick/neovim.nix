# Ensure neovim has LSP/formatter dependencies available outside of dev shells.
{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      # conform
      gofumpt
      gotools # goimports
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
      nodejs_22
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      xsel
    ];

  # vi -> nvim alias
  # vim -> vim
  # nvim -> nvim
  programs.neovim = {
    enable = true;
    viAlias = true;
  };
}
