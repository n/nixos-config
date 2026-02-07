# Setup macOS

## System Settings

- Energy -> Prevent automatic sleep when the display is off (mini)
- Appearance -> Dark Theme
- General -> Sharing -> Computer Name: [hostname]
- iCloud -> Drive -> Desktop & Documents Folders
- Open all apps in the dock
- General -> Storage: clear recommendations and unnecessary apps
- Control Center -> Show Bluetooth + Weather in Menu Bar
- Siri -> Press Right Command Key Twice + Irish (Voice 2)
- Spotlight -> Disable Help Apple Improve Search, Disable Siri Suggestions
- Keyboard Shortcuts -> App Shortcuts -> Mail: Message->Archive ⌘A

## Wi-Fi

- Details -> Private Wi-Fi Address: Off

## Configure Sudo

```bash
sudo visudo
# %admin ALL=(ALL) NOPASSWD: ALL
```

## Create SSH key

ssh-keygen -t ed25519 -C "$USER@$HOSTNAME"

## Install Nix from Determinate Systems

```bash
# Revist this on next install. Determinate moved away from installing upstream nix.
# Maybe we want: https://github.com/NixOS/nix-installer
/bin/bash -c "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    NIX_INSTALLER_DIAGNOSTIC_ENDPOINT="" sh -s -- install"
```

## Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /Users/nick/.bash_profile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/nick/.bash_profile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Nix Configuration

```bash
git clone nick@home.lab.internal:git/nixos-config.git
cd nixos-config
echo "/run/current-system/sw/bin/bash" | sudo tee -a /etc/shells
chsh -s /run/current-system/sw/bin/bash
```
