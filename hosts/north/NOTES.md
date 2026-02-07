# Setup NixOS with tmpfs as root

## Create partitions

```bash
# wipefs -a $DISK

DISK=/dev/DISK
SWAP_SIZE=65536 # 64GiB

parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MiB 513MiB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart SWAP linux-swap 513MiB $((513 + SWAP_SIZE))MiB
parted $DISK -- mkpart NIX ext4 $((513 + SWAP_SIZE))MiB 100%

# Check alignment

for i in {1..3}; do parted $DISK -- align-check optimal $i; done
lsblk
parted $DISK -- unit MiB print

# Encrypt the nix partition

cryptsetup luksFormat /dev/disk/by-partlabel/NIX
cryptsetup luksOpen /dev/disk/by-partlabel/NIX cryptednix

# Create filesystems

mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/ESP
mkswap -L swap /dev/disk/by-partlabel/SWAP
swapon /dev/disk/by-partlabel/SWAP
mkfs.ext4 -L nix /dev/mapper/cryptednix

# Mount filesystems

mount -t tmpfs none /mnt
mkdir -v -p /mnt/{boot,nix,etc/nixos}
mount -o umask=0077 /dev/disk/by-label/boot /mnt/boot
mount /dev/mapper/cryptednix /mnt/nix

# Generate configuration

nixos-generate-config --root /mnt
```

## Update configuration

- Update hardware-configuration.nix
- Copy /var/lib/sbctl to /mnt/var/lib/sbctl

## Install NixOS

```bash
nixos-install --root /mnt --no-root-passwd --flake .#north

# Now copy files over that are needed. For example: nixos-config
```

## Enable boot with TPM2

```bash
sbctl create-keys
systemd-cryptenroll /dev/disk/by-partlabel/NIX --tpm2-device=auto --tpm2-pcrs=7 --wipe-slot=tpm2
```

## Discover files in tmpfs that should be persisted

```bash
touch /tmp/now
# Do something
sudo find / -xdev -type f -newer /tmp/now
```
