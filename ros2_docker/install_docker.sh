#!/usr/bin/env bash
set -e

echo "=========================================="
echo " Installing Docker on Ubuntu Host (26.10) "
echo "=========================================="

if command -v docker &> /dev/null; then
    echo "[✓] Docker is already installed: $(docker --version)"
else
    echo "[i] Installing Docker packages via apt..."
    sudo apt update
    sudo apt install -y docker.io docker-buildx docker-compose-v2
fi

echo "[i] Ensuring Docker service is active and enabled..."
sudo systemctl enable --now docker

TARGET_USER="${SUDO_USER:-$USER}"
echo "[i] Adding user '$TARGET_USER' to the 'docker' group..."
sudo usermod -aG docker "$TARGET_USER"

echo "=========================================="
echo "[✓] Docker installation completed!"
echo "NOTE: To apply group changes without logging out, run:"
echo "      newgrp docker"
echo "=========================================="
