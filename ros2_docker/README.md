# ROS 2 Development Environment (Ubuntu 24.04 Noble & ROS 2 Jazzy)

This repository sets up a containerized development environment for **ROS 2 Jazzy Jalisco** running inside **Ubuntu 24.04 LTS (Noble Numbat)** on your host **Ubuntu 26.10** machine.

---

## 1. Quick Start

### Step 1: Install Docker on the Host (One-Time Setup)
Docker is not installed on the host yet. Run the provided helper script:

```bash
cd ~/ros2_docker
./install_docker.sh
```

*(This runs `sudo apt install docker.io docker-compose-v2` and adds your user to the `docker` group so you don't need `sudo` for Docker).*

If you don't reboot or log out immediately, activate the group in your current terminal:
```bash
newgrp docker
```

---

### Step 2: Build & Enter the Container
Run the launcher script:

```bash
./run.sh
```

This will automatically:
1. Enable local X11 display permissions for GUI apps (`xhost`).
2. Pull `osrf/ros:jazzy-desktop` (Ubuntu 24.04 Noble) and build the image with `tmux`, `git`, build tools, and user configuration.
3. Start the container in the background.
4. Drop you directly into an interactive bash shell inside Ubuntu 24.04 with ROS 2 Jazzy pre-sourced.

---

## 2. Features Included

- **Base OS**: Ubuntu 24.04 LTS (Noble Numbat)
- **ROS 2 Distro**: ROS 2 Jazzy Jalisco (Desktop)
- **Pre-installed Tools**:
  - `tmux` (with mouse support and 256 colors pre-configured)
  - `git`, `curl`, `wget`, `vim`, `nano`, `htop`, `tree`
  - `build-essential`, `cmake`, `gdb`, `valgrind`
  - `python3-colcon-common-extensions`, `python3-rosdep`, `python3-vcstool`
- **User Integration**:
  - Container user matches your host UID (`1000`) and GID (`1000`), meaning files edited in the container will not end up with root permission locks on your host.
  - Passwordless `sudo` inside the container if you need to `apt install` extra libraries.
- **Workspace Mounting**:
  - `~/ros2_docker/ros2_ws` on your host is mounted to `/home/vhorvat/ros2_ws` in the container.
  - Changes made inside or outside the container persist automatically.
- **Networking & GUI Support**:
  - `network_mode: host` for seamless ROS 2 DDS node discovery across machines.
  - Host X11 forwarding configured for GUI tools like `rviz2` or `rqt`.

---

## 3. Useful Commands

### Sourcing & Verification (Inside Container)
The container automatically sources ROS 2 on every shell startup. You can verify with:

```bash
ros2 doctor
ros2 pkg list | grep demo
```

Run a quick test publisher & listener:
```bash
# Terminal 1:
ros2 run demo_nodes_cpp talker

# Terminal 2 (open another terminal with ./run.sh or tmux):
ros2 run demo_nodes_py listener
```

### Opening More Terminals in the Running Container
You can simply start `tmux` inside the container, or from your host run:
```bash
docker exec -it ros2_jazzy_container /bin/bash
```

### Stopping the Container
```bash
cd ~/ros2_docker
docker compose down
```
