# == MY ARCH SETUP INSTALLER == #
#part1
printf '\033c'
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
printf "\e[0;34mEnter the drive: \e[0m" 
read drive
cfdisk $drive 
printf "\e[0;34mEnter the EFI partition: \e[0m" 
read efipartition
mkfs.fat -F32 $efipartition 
read -p "Did you also create swap partition? [y/n]" answer
if [[ $answer = y ]] ; then
  printf "\e[0;34mEnter swap partition: \e[0m" 
  read swappartition
  mkswap $swappartition
  swapon $swappartition
fi
printf "\e[0;34mEnter the linux filesystem partition: \e[0m" 
read partition
mkfs.ext4 $partition 
echo "mounting $partition to /mnt"
mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2/d'  arch_install.sh > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2 
printf '\033c'
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
printf "\e[0;34mHostname: \e[0m"
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober
printf "\e[0;34mEnter EFI partition: \e[0m"
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm xorg-server xorg-xprop xorg-xkill xorg-xsetroot xorg-xinit \
    noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-font-awesome \
    awesome-terminal-fonts libnotify dunst ntfs-3g \
    jq mpv ncdu maim transmission-cli yt-dlp cowsay \
    pacman-contrib pavucontrol rsync ripgrep ueberzug ffmpegthumbnailer python-pywal \
    sxiv xdotool xwallpaper zip unzip wget pcmanfm \
    fzf man-db pipewire pipewire-pulse xcompmgr pamixer \
    xclip sxhkd imagemagick connman wpa_supplicant git dash arc-gtk-theme papirus-icon-theme \
    neovim lua rustup xdg-user-dirs mpd ncmpcpp unclutter \
    zsh zsh-autosuggestions zathura zathura-pdf-poppler 
    
systemctl enable connman.service 
rm /bin/sh
ln -s dash /bin/sh
# echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
printf "\e[0;34mEnter Username: \e[0m"
read username
useradd -m -G wheel -s /bin/zsh $username
passwd $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit 

#part3
printf '\033c'
cd $HOME
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:krolyxon/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
# dwm : Window Manager
git clone --depth=1 git@github.com:krolyxon/dwm.git ~/.local/src/dwm
sudo make -C ~/.local/src/dwm install

# st: Terminal
git clone --depth=1 git@github.com:krolyxon/st.git ~/.local/src/st
sudo make -C ~/.local/src/st install

# dmenu: Program Menu
git clone --depth=1 git@github.com:krolyxon/dmenu.git ~/.local/src/dmenu
sudo make -C ~/.local/src/dmenu install

# nvim: Text editor
git clone --depth=1 git@github.com:krolyxon/nvim.git ~/.config/nvim

# keyd configuration: key remapping
sudo mkdir -p /etc/keyd
sudo wget https://raw.githubusercontent.com/krolyxon/keyd-config/master/default.conf -P /etc/keyd/

# paru: AUR helper
git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -sri && cd .. && rm -rf paru-bin
paru -S --noconfirm htop-vim nerd-fonts-jetbrains-mono lf-bin \
    zsh-fast-syntax-highlighting-git keyd-git librewolf-bin

chsh -s $(which zsh)
printf "bro do you want to install that fucking nvidia-390xx drivers? (y/n): " 
read driver
if [[ $driver = y ]]; then
  paru -S --noconfirm nvidia-390xx
fi

ln -s ~/.config/x11/xinitrc .xinitrc
ln -s ~/.config/shell/profile .zprofile
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dots config --local status.showUntrackedFiles no
exit
