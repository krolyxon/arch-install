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
pacman -S --noconfirm hyprland waybar hyprlock hyprpaper hyprpolkitagent hyprshot hyprsunset swaync \
    noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono-nerd ttf-font-awesome \
    awesome-terminal-fonts bat libnotify ntfs-3g \
    jq mpv ncdu transmission-cli yt-dlp cowsay \
    pacman-contrib pavucontrol rsync ripgrep ueberzug python-pywal \
    imlib2 zip unzip wget pcmanfm \
    fzf man-db pipewire pipewire-pulse xcompmgr pamixer \
    sxhkd imagemagick lf network-manager git dash arc-gtk-theme papirus-icon-theme \
    neovim lua xdg-user-dirs mpd ncmpcpp unclutter \
    zsh zsh-autosuggestions zathura zathura-pdf-poppler

```

17. Enable networkmanager
```
# network manager
systemctl enable NetworkManager.service
```

18. set shell
```
rm /bin/sh
ln -s dash /bin/sh
```

19. Set user permissions
```
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
```

20. Create user
```
useradd -m -G wheel -s /bin/zsh $username
passwd $username
```

21. Setup dotfiles
```
cd $HOME
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:krolyxon/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
```

22. nsxiv: image viewer
```
git clone --depth=1 git@github.com:krolyxon/nsxiv.git ~/.local/src/nsxiv
sudo make -C ~/.local/src/nsxiv install
```

23. nvim: Text editor
```
git clone --depth=1 git@github.com:krolyxon/nvim.git ~/.config/nvim
```

24. paru: AUR helper
```
git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -sri && cd .. && rm -rf paru-bin
paru -S --noconfirm htop-vim zsh-fast-syntax-highlighting-git keyd-git librewolf-bin
```

25. set zsh as default shell
```
chsh -s $(which zsh)
```

26. some symlinks and git alias
```
ln -s ~/.config/shell/profile .zprofile
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dots config --local status.showUntrackedFiles no
```
