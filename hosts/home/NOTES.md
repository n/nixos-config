# Setup NixOS with tmpfs as root

## Create partitions

```bash
# dd if=/dev/zero of=$DISK bs=4M count=10 status=progress

DISK=/dev/sda
SWAP_SIZE=8192 # 8GiB

parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MiB 513MiB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart swap linux-swap 513MiB $((513 + SWAP_SIZE))MiB
parted $DISK -- mkpart cryptnix ext4 $((513 + SWAP_SIZE))MiB 100%

# Check alignment

for i in {1..3}; do parted $DISK -- align-check optimal $i; done
lsblk
parted $DISK -- unit MiB print

# Encrypt the nix partition

cryptsetup luksFormat /dev/disk/by-partlabel/cryptnix
cryptsetup luksOpen /dev/disk/by-partlabel/cryptnix cryptednix

# Create filesystems

mkfs.fat -F 32 -n boot ${DISK}1
mkswap -L swap ${DISK}2
swapon ${DISK}2
mkfs.ext4 -L nix /dev/mapper/cryptednix

# Mount filesystems

mount -t tmpfs none /mnt
mkdir -v -p /mnt/{boot,nix,etc/nixos}
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
mount /dev/mapper/cryptednix /mnt/nix

# Bind mount the persistent configuration / logs

mkdir -v -p /mnt/nix/persist/{etc/nixos,etc/ssh}
mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos

# Generate configuration

nixos-generate-config --root /mnt
```

## Copy the configuration

## Install NixOS

```bash
nixos-install --no-root-passwd
```

## Later

```bash
# NixOS commands

nixos-rebuild switch --flake .
nix-collect-garbage -d

# Enable boot with TPM2

systemd-cryptenroll /dev/disk/by-partlabel/cryptnix --tpm2-device=auto --tpm2-pcrs=0,2,4,7 --wipe-slot=tpm2

# Generate secure boot keys
sbctl create-keys
```
