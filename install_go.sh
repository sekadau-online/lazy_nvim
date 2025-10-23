#!/usr/bin/env bash
set -e

echo "===================================="
echo "🚀 Installing Go (Golang) latest stable"
echo "===================================="

# Detect architecture
ARCH=$(uname -m)
GO_VERSION="1.23.2"

if [ "$ARCH" = "x86_64" ]; then
  GO_ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  GO_ARCH="arm64"
else
  echo "❌ Unsupported architecture: $ARCH"
  exit 1
fi

# Remove old Go if exists
if [ -d "/usr/local/go" ]; then
  echo "🧹 Removing old Go installation..."
  sudo rm -rf /usr/local/go
fi

# Download and extract
echo "📦 Downloading Go ${GO_VERSION} for ${GO_ARCH}..."
curl -L "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -o /tmp/go.tar.gz

echo "📂 Extracting to /usr/local..."
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

# Add to PATH
PROFILE="$HOME/.bashrc"
if ! grep -q "/usr/local/go/bin" "$PROFILE"; then
  echo "export PATH=\$PATH:/usr/local/go/bin" >> "$PROFILE"
fi

# Apply immediately
export PATH=$PATH:/usr/local/go/bin

# Verify
echo "===================================="
go version || { echo "❌ Go installation failed"; exit 1; }
echo "✅ Go successfully installed!"

# Install gopls LSP
echo "------------------------------------"
echo "🧠 Installing gopls (Go Language Server)..."
go install golang.org/x/tools/gopls@latest

# Add GOPATH/bin to PATH
if ! grep -q "\$(go env GOPATH)/bin" "$PROFILE"; then
  echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >> "$PROFILE"
fi
export PATH=$PATH:$(go env GOPATH)/bin

# Verify gopls
echo "✅ gopls installed at: $(which gopls)"
echo "✅ gopls version: $(gopls version)"
echo "===================================="
echo "🎉 Go and gopls installation complete!"
