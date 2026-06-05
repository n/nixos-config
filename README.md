# Nick's Nix

My personal Nix configuration and dotfiles.

## Highlights

- Physical NixOS hosts use an ephemeral root filesystem (`/` on `tmpfs`) with explicit persistence under `/nix/persist` via impermanence.
- macOS hosts are managed with `nix-darwin`, including declarative Homebrew and App Store management.
- Shared user environment and dotfiles are managed via Home Manager modules.
- Secure Boot + TPM2 unlock are configured for physical NixOS hosts (`lanzaboote`, `sbctl`, `systemd-cryptenroll`).

## Commands

```sh
make switch  # Apply configuration for current host
make gc      # Garbage collect and clean caches
```

## Layout

- `flake.nix`: flake inputs, host definitions, and shared module composition
- `hosts/`: machine-specific modules, plus `nixos-common/` and `darwin-common/` shared per-platform config
- `users/nick/`: Home Manager user environment
- `data/`: cross-platform shared data (SSH keys)

Host bootstrap and installation notes live under `hosts/`, usually as `NOTES.md`.
