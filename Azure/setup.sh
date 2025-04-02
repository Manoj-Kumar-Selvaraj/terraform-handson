#!/bin/bash  # Correct Shebang

# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Create keyrings directory if not exists
sudo mkdir -p /etc/apt/keyrings

# Add Microsoft GPG key
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
   gpg --dearmor |
   sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null

# Get Ubuntu version
SUITE=$(lsb_release -cs)

# Add Microsoft Azure CLI repository
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $SUITE main" |
    sudo tee /etc/apt/sources.list.d/microsoft.list

# Set package pinning preferences
cat << EOF | sudo tee /etc/apt/preferences.d/99-microsoft
Package: *
Pin: origin "packages.microsoft.com"
Pin-Priority: 1001
EOF

# Update package list again after adding new repository
sudo apt-get update

# Install Azure CLI
sudo apt-get install -y azure-cli
