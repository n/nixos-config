# Nick's Nix

My personal Nix configuration and dotfiles.

## Highlights

- NixOS hosts use an ephemeral root filesystem (`/` on `tmpfs`) with explicit persistence under `/nix/persist` via impermanence.
- macOS hosts are managed with `nix-darwin`, including declarative Homebrew and App Store management.
- Shared user environment and dotfiles are managed via Home Manager modules.
- Secure Boot + TPM2 unlock are part of the Linux baseline (`lanzaboote`, `sbctl`, `systemd-cryptenroll`).

## Commands

```sh
make switch  # Apply configuration for current host
make gc      # Garbage collect and clean caches
```

## Layout

- `flake.nix`: host definitions and shared module composition
- `hosts/`: machine-specific NixOS/nix-darwin modules
- `users/nick/`: Home Manager user environment
- `common/`: shared user and keys

Host bootstrap and installation notes live in `hosts/*/NOTES.md`.
