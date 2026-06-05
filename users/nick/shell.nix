{ config, pkgs, ... }:
let
  shellAliases = {
    "l." = if pkgs.stdenv.isDarwin then "ls -d .*" else "ls -d .* --color=auto";
    ll = if pkgs.stdenv.isDarwin then "ls -l" else "ls -l --color=auto";
    ls = if pkgs.stdenv.isDarwin then "ls -G" else "ls --color=auto";
    grep = "grep --color=auto";

    myip = "curl -fsS https://httpbin.org/ip | jq -r .origin";
    dudu = "du -hd1 | sort -h; ls -Slh | tail -n +2 | head -3";
    hd = "curl -I -X GET";
    tmux-peak = "tmux capture-pane -p";
    ls-ports = "sudo lsof -i -P -n | grep LISTEN";
    find-non-ascii = "rg \"[^[:ascii:]]\"";
    find-files-since-boot = "sudo find / -xdev -type f -newer /tmp/since-boot";
    cd-obsidian = "cd ~/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents";

    dotenv = "npx -y dotenv-cli -e .env --";
    claude-yolo = "claude --dangerously-skip-permissions";
    codex-yolo = "codex --dangerously-bypass-approvals-and-sandbox";
  };
in
{
  home.packages = with pkgs; [
    bat
    bun
    curl
    fd
    gh
    gnumake
    jq
    pnpm
    ripgrep
    tree
    unzip
    uv
    wget
    duckdb
  ];

  # Add ~/.local/bin to PATH
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # Disable telemetry for various tools.
  home.sessionVariables = {
    ASTRO_TELEMETRY_DISABLED = 1; # Astro
    DISABLE_TELEMETRY = 1; # Claude code
    HOMEBREW_NO_ANALYTICS = 1; # Homebrew
    NEXT_TELEMETRY_DISABLED = 1; # Next.js
  };

  # Bash configuration.
  programs.bash = {
    enable = true;
    historyControl = [
      "ignoreboth"
      "erasedups"
    ];
    historyFileSize = -1;
    historySize = -1;
    initExtra = ''
      # Append to history after each command.
      export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

      # Add SSH keys to the agent if not already added.
      if [ -f ~/.ssh/id_ed25519 ]; then
        [ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"
        ssh-add -l >/dev/null 2>&1 || ssh-add ~/.ssh/id_ed25519
      fi

      # Load Homebrew environment if on macOS and Homebrew is installed.
      if [ -z "$HOMEBREW_PREFIX" ]; then
        if [ -f /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      fi
    '';
    inherit shellAliases;
  };

  # Fish configuration.
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fish_vi_key_bindings

      # Add SSH keys to the agent if not already added.
      if test -f ~/.ssh/id_ed25519
        if not set -q SSH_AUTH_SOCK
          eval (ssh-agent -c)
        end
        ssh-add -l >/dev/null 2>&1; or ssh-add ~/.ssh/id_ed25519
      end

      # Load Homebrew environment if on macOS and Homebrew is installed.
      if not set -q HOMEBREW_PREFIX
        if test -f /opt/homebrew/bin/brew
          eval (/opt/homebrew/bin/brew shellenv)
        end
      end

      # Helper function to load .env files
      function load_env
        for line in (cat $argv | string match -rv '^#|^$')
          set -l item (string split -m 1 = $line)
          set -gx $item[1] $item[2]
        end
      end
    '';
    inherit shellAliases;
  };

  # Starship configuration for a customizable prompt.
  programs.starship = {
    enable = true;
  };

  # FZF configuration.
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --follow --hidden --type f --strip-cwd-prefix";
    changeDirWidgetCommand = "fd --follow --hidden --type d --strip-cwd-prefix";
    fileWidgetCommand = "fd --follow --hidden --type f --strip-cwd-prefix";
  };

  # Direnv configuration for automatic environment loading.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable comma to run software without installing it.
  programs.nix-index-database = {
    comma.enable = true;
  };
}
