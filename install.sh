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

# Remove any existing sw-lin-public configuration
echo "Checking for existing repository configuration..."
sudo sed -i '/\[sw-lin-public\]/,+2d' /etc/pacman.conf

# Add repository to pacman.conf
echo "Adding repository to pacman.conf..."
echo -e "\n[sw-lin-public]" | sudo tee -a /etc/pacman.conf
echo "SigLevel = Optional TrustAll" | sudo tee -a /etc/pacman.conf
echo "Server = https://raw.githubusercontent.com/Ogyeet10/sw-lin-public-repo/main/\$arch" | sudo tee -a /etc/pacman.conf

# Update package database and install
echo "Updating package database..."
sudo pacman -Sy || error_exit "Failed to sync package database"

echo "Installing starware..."
sudo pacman -S --noconfirm starware || error_exit "Failed to install starware"

# Verify installation
if pacman -Qi starware >/dev/null 2>&1; then
    echo "Installation completed successfully!"
    echo ""
    echo "Setting up services..."
    
    # Enable and start the system service
    echo "Enabling system service..."
    sudo systemctl enable starware.service || error_exit "Failed to enable system service"
    sudo systemctl start starware.service || error_exit "Failed to start system service"
    
    # Note: User agents now auto-start via XDG autostart (no manual enabling needed)
    
    echo ""
    echo "Setup complete!"
    echo "System service: starware.service (enabled and started)"
    echo "User agents: Auto-start via XDG autostart (/etc/xdg/autostart/starware-user.desktop)"
    echo ""
    echo "User agents will automatically start when users log into graphical sessions."
    echo "To check system service status: sudo systemctl status starware.service"
    echo "To manually control user agents: systemctl --user start/stop starware-user.service"
    
else
    error_exit "Installation verification failed"
fi 