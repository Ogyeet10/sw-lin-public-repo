#!/bin/bash

echo "Adding repository signing key..."
curl -s https://raw.githubusercontent.com/Ogyeet10/sw-lin-public-repo/main/sw-lin-public.key | sudo pacman-key --add -
sudo pacman-key --lsign-key aidanml05@gmail.com

if ! grep -q "\[sw-lin-public\]" /etc/pacman.conf; then
    echo "Adding repository to pacman.conf..."
    echo -e "\n[sw-lin-public]" | sudo tee -a /etc/pacman.conf
    echo "SigLevel = Required DatabaseOptional" | sudo tee -a /etc/pacman.conf
    echo "Server = https://raw.githubusercontent.com/Ogyeet10/sw-lin-public-repo/main/\$arch" | sudo tee -a /etc/pacman.conf
fi

echo "Updating package database..."
sudo pacman -Sy
echo "Installing starware..."
sudo pacman -S --noconfirm starware

echo "Installation complete!"