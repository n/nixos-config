{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
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
    shellAliases = {
      "l." = if pkgs.stdenv.isDarwin then "ls -d .*" else "ls -d .* --color=auto";
      ll = if pkgs.stdenv.isDarwin then "ls -l" else "ls -l --color=auto";
      ls = if pkgs.stdenv.isDarwin then "ls -G" else "ls --color=auto";

      myip = "curl -fsS https://httpbin.org/ip | jq -r .origin";
      dudu = "du -hd1 | sort -h; ls -Slh | tail -n +2 | head -3";
      dudu2 = "sudo tree -xh --du | grep -E '^(├──|└──)\\s+.*'";
      hd = "curl -I -X GET";
      tmux-peak = "tmux capture-pane -p";
      ls-ports = "sudo lsof -i -P -n | grep LISTEN";
      find-emdash = "rg '—' .";
      find-files-since-boot = "sudo find / -xdev -type f -newer /tmp/since-boot";
      cd-obsidian = "cd '~/Library/Mobile Documents/iCloud~md~obsidian/Documents'";

      dotenv = "npx -y dotenv-cli -e .env --";
      claude-yolo = "claude --dangerously-skip-permissions";
      gemini = "npx -y @google/gemini-cli";
      gemini-yolo = "npx -y @google/gemini-cli --yolo";
      codex = "npx -y @openai/codex --search";
      codex-yolo = "npx -y @openai/codex --dangerously-bypass-approvals-and-sandbox";

      egrep = "grep -E --color=auto";
      fgrep = "grep -F --color=auto";
      grep = "grep --color=auto";
      xzegrep = "xzegrep --color=auto";
      xzfgrep = "xzfgrep --color=auto";
      xzgrep = "xzgrep --color=auto";
      zegrep = "zegrep --color=auto";
      zfgrep = "zfgrep --color=auto";
      zgrep = "zgrep --color=auto";
    };
  };

  # Fish configuration.
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  # Starship configuration for a customizable prompt.
  programs.starship = {
    enable = true;
  };

  # FZF configuration.
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --strip-cwd-prefix";
    changeDirWidgetCommand = "fd --type d --strip-cwd-prefix";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix";
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
