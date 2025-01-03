#!/bin/bash

# Exit on any error
set -e

# Function to handle errors
error_exit() {
    echo "Error: $1"
    exit 1
}

# Add the repository key
echo "Adding repository signing key..."
curl -fL https://raw.githubusercontent.com/Ogyeet10/sw-lin-public-repo/main/sw-lin-public.key > /tmp/sw-lin-public.key || error_exit "Failed to download key"
sudo pacman-key --add /tmp/sw-lin-public.key || error_exit "Failed to add key to pacman"
sudo pacman-key --lsign-key aidanml05@gmail.com || error_exit "Failed to locally sign key"
rm /tmp/sw-lin-public.key

# Add repository to pacman.conf if not already present
if ! grep -q "\[sw-lin-public\]" /etc/pacman.conf; then
    echo "Adding repository to pacman.conf..."
    echo -e "\n[sw-lin-public]" | sudo tee -a /etc/pacman.conf
    echo "SigLevel = Optional TrustAll" | sudo tee -a /etc/pacman.conf
    echo "Server = https://raw.githubusercontent.com/Ogyeet10/sw-lin-public-repo/main/\$arch" | sudo tee -a /etc/pacman.conf
fi

# Update package database and install
echo "Updating package database..."
sudo pacman -Sy || error_exit "Failed to sync package database"

echo "Installing starware..."
sudo pacman -S --noconfirm starware || error_exit "Failed to install starware"

# Verify installation
if pacman -Qi starware >/dev/null 2>&1; then
    echo "Installation completed successfully!"
else
    error_exit "Installation verification failed"
fi 