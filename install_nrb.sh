#!/usr/bin/env bash

set -e

INSTALL_DIR="/opt/nrb"
ZIP_URL="https://github.com/notroboy67-htp/Makk/archive/refs/heads/main.zip"

echo "=========================================="
echo "          NRB FREE DOMAINS"
echo "          ONE CLICK INSTALLER"
echo "=========================================="

if [ "$(id -u)" != "0" ]; then
    echo "Please run this installer as root."
    exit 1
fi

echo "[1/7] Updating system..."
apt-get update -y

echo "[2/7] Installing requirements..."
apt-get install -y curl unzip ca-certificates

echo "[3/7] Installing Node.js 22..."

if command -v node >/dev/null 2>&1; then
    NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
else
    NODE_MAJOR=0
fi

if [ "$NODE_MAJOR" -lt 22 ]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
fi

echo "Node: $(node -v)"
echo "NPM:  $(npm -v)"

echo "[4/7] Downloading NRB Free Domains..."

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

cd /tmp

rm -f nrb.zip
rm -rf nrb-extract

curl -L "$ZIP_URL" -o nrb.zip

echo "[5/7] Extracting project..."

mkdir -p nrb-extract
unzip -q nrb.zip -d nrb-extract

PROJECT_DIR=$(find nrb-extract -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -z "$PROJECT_DIR" ]; then
    echo "ERROR: Project extraction failed."
    exit 1
fi

cp -a "$PROJECT_DIR"/. "$INSTALL_DIR"/

cd "$INSTALL_DIR"

echo "[6/7] Installing NRB..."

npm install
npm run build

echo "[7/7] Starting NRB..."

echo ""
echo "=========================================="
echo "       NRB FREE DOMAINS INSTALLED"
echo "=========================================="
echo ""
echo "Port: 5000"
echo ""
echo "Opening:"
echo "http://YOUR_SERVER_IP:5000"
echo ""

exec node backend/server.mjs
