# https://daiderd.com/nix-darwin/manual/index.html

{
  lib,
  pkgs,
  hostname,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    vim
    tmux
  ];
  environment.variables = {
    EDITOR = "vim";
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      "mas"
    ];

    casks = [
      "chatgpt"
      "claude"
      "claude-code"
      "clickup"
      "codex-app"
      "container"
      "cursor"
      "discord"
      "figma"
      "firefox"
      "front"
      "ghostty"
      "github"
      "google-chrome"
      "linear-linear"
      "netnewswire"
      "obsidian"
      "ollama-app"
      "postman"
      "raspberry-pi-imager"
      "syncthing-app"
      "visual-studio-code"
      "zoom"
    ]
    ++ lib.optionals (hostname == "mbp") [
      "icon-composer"
      "steam"
    ]
    ++ lib.optionals (hostname == "mini") [
      "blender"
      "jabra-direct"
      "logi-options+"
      "prusaslicer"
    ];

    masApps = {
      "1Password 7" = 1333542190;
      "AdGuard for Safari" = 1440147259;
      "Flock" = 883594849;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "Pixelmator Pro" = 1289583905;
      "Slack" = 803453959;
      "Tailscale" = 1475387142;
      "TestFlight" = 899247664;
      "Things" = 904280696;
      "uBlock Origin Lite" = 6745342698;
      "UTM" = 1538878817;
    }
    // lib.optionalAttrs (hostname == "mbp") {
      "iMovie" = 408981434;
      "Xcode" = 497799835;
    };
  };

  system.defaults = {
    dock.autohide = true;
    loginwindow.GuestEnabled = false;

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 5;
}
