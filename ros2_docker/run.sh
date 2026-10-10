#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

# Ensure workspace folder exists on host
mkdir -p "$DIR/ros2_ws/src"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "=========================================================="
    echo "[!] Docker is not installed on this Ubuntu host."
    echo "    Please run the installation script first:"
    echo "      ./install_docker.sh"
    echo "    (or: sudo apt update && sudo apt install -y docker.io docker-compose-v2)"
    echo "=========================================================="
    exit 1
fi

# Check Docker daemon socket access
if ! docker info &> /dev/null; then
    echo "=========================================================="
    echo "[!] Cannot access the Docker daemon socket."
    echo "    Your user '$USER' needs to be added to the docker group:"
    echo "      sudo usermod -aG docker \$USER"
    echo "      newgrp docker"
    echo "=========================================================="
    exit 1
fi

# Allow local GUI/X11 display access for tools like RViz2 / rqt
if command -v xhost &> /dev/null; then
    xhost +local:root >/dev/null 2>&1 || true
    xhost +local:"$USER" >/dev/null 2>&1 || true
fi

CONTAINER_NAME="ros2_jazzy_container"

# Check if container is already running
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "[✓] Container '$CONTAINER_NAME' is already running."
    echo "[i] Attaching interactive shell..."
    docker exec -it "$CONTAINER_NAME" /bin/bash
    exit 0
fi

# If container exists but stopped, start it
if [ "$(docker ps -aq -f status=exited -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "[i] Starting existing container '$CONTAINER_NAME'..."
    docker start "$CONTAINER_NAME" > /dev/null
    echo "[i] Attaching interactive shell..."
    docker exec -it "$CONTAINER_NAME" /bin/bash
    exit 0
fi

# Detect docker compose command
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo "[!] Docker Compose plugin or binary not found. Please install docker-compose-v2."
    exit 1
fi

# Otherwise build and launch via Docker Compose
echo "[i] Building and starting ROS 2 Jazzy (Ubuntu 24.04) container..."
$COMPOSE_CMD up -d --build

echo "[✓] Container started successfully."
echo "[i] Entering interactive shell inside the container..."
docker exec -it "$CONTAINER_NAME" /bin/bash
