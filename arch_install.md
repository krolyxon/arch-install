# Arch Install

## Connect to Internet
If you are using wifi, use [iwd](https://wiki.archlinux.org/title/Iwd)
```
device list
station *device* get-networks
station *d
```

## Install Guide

1. Turn on parallel downloads
``sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf``

2. Install archlinux keyring
``pacman --noconfirm -Sy archlinux-keyring``

3. Load layout, set time
```
loadkeys us
timedatectl set-ntp true
```

4. Create ext4, efi, swap partition
```
lsblk
cfdisk /dev/sdx or /dev/nvme0x

# Efi partition
mkfs.fat -F32 $efipartition

# Swap partition
mkswap $swappartition
swapon $swappartition

# ext4 partition
mkfs.ext4 $partition
```

5. Mount linux partition to /mnt
``mount $partition /mnt``

6. Pacstrap
```
pacstrap /mnt base base-devel linux linux-firmware
```

7. genstab
```
genfstab -U /mnt >> /mnt/etc/fstab
```

8. chroot
```
arch-chroot /mnt
```

9. set timezone
```
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
```

10. set hardware clock from system clock
```
hwclock --systohc
```

11. set locale
```
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
```

12. set hostname
```
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
```

13. Initramfs
```
mkinitcpio -P
```

14. Set root password
```
passwd
```

15. install grub
```
pacman --noconfirm -S grub efibootmgr os-prober
mkdir /boot/efi
mount $efipartition /boot/efi

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck

sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg
```

16. Install all the required user packages
```
pacman -S --noconfirm networkmanager git
```

17. Enable networkmanager
```
systemctl enable NetworkManager.service
```

18. Set user permissions
```
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
```

19. Create user
```
useradd -m -G wheel $username
passwd $username
```

