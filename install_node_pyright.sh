#!/usr/bin/env bash
set -e

echo "===================================="
echo " 🚀 Installing Node.js (LTS) & Pyright"
echo "===================================="

# Detect existing node
if command -v node >/dev/null 2>&1; then
  echo "🔹 Detected existing Node.js: $(node -v)"
  echo "Removing old Node.js version..."
  sudo apt remove -y nodejs npm || true
fi

# Install curl if missing
if ! command -v curl >/dev/null 2>&1; then
  echo "Installing curl..."
  sudo apt update && sudo apt install -y curl
fi

# Add NodeSource repo (Node 20 LTS)
echo "Adding NodeSource repository..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js and npm
echo "Installing Node.js and npm..."
sudo apt install -y nodejs

# Verify installation
echo "===================================="
echo "✅ Node.js version: $(node -v)"
echo "✅ npm version: $(npm -v)"
echo "===================================="

# Install Pyright globally
echo "Installing Pyright LSP..."
sudo npm install -g pyright

# Verify Pyright
echo "===================================="
echo "✅ Pyright version: $(pyright --version)"
echo "Installation complete!"
echo "===================================="
