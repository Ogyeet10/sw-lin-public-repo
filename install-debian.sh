#!/bin/bash

# Exit on any error
set -e

# Function to handle errors
error_exit() {
    echo "Error: $1"
    exit 1
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script must be run as root or with sudo"
fi

# Detect Debian-based distribution
if [ ! -f /etc/debian_version ]; then
    error_exit "This script is intended for Debian-based systems only"
fi

# Add GPG key for package verification - Modern approach (apt-key is deprecated)
echo "Adding repository signing key..."
curl -fL https://raw.githubusercontent.com/Ogyeet10/sw-lin-public-repo/main/sw-lin-public.key > /tmp/sw-lin-public.key || error_exit "Failed to download key"

# Create keyring directory if it doesn't exist
mkdir -p /etc/apt/keyrings/

# Convert and store the key in apt's trusted.gpg.d directory
gpg --dearmor < /tmp/sw-lin-public.key > /etc/apt/keyrings/sw-lin-public.gpg || error_exit "Failed to add repository key"
rm /tmp/sw-lin-public.key

# Add repository to sources.list.d with signed-by option
echo "Adding Starware repository..."
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/sw-lin-public.gpg] https://raw.githubusercontent.com/Ogyeet10/sw-lin-public-repo/main/debian stable main" > /etc/apt/sources.list.d/starware.list || error_exit "Failed to add repository"

# Update package database and install
echo "Updating package database..."
apt-get update || error_exit "Failed to update package database"

echo "Installing starware..."
apt-get install -y starware || error_exit "Failed to install starware"

# Verify installation
if dpkg -l starware >/dev/null 2>&1; then
    echo "Installation completed successfully!"
else
    error_exit "Installation verification failed"
fi 