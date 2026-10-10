# Base image: Official OSRF ROS 2 Jazzy Desktop on Ubuntu 24.04 Noble Numbat
FROM osrf/ros:jazzy-desktop

# Prevent interactive prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive

# Arguments for matching host user UID/GID
ARG USERNAME=vhorvat
ARG USER_UID=1000
ARG USER_GID=1000

# Install essential command-line tools, build tools, and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    tree \
    bash-completion \
    build-essential \
    cmake \
    gdb \
    valgrind \
    python3-pip \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    iproute2 \
    net-tools \
    iputils-ping \
    mesa-utils \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Initialize rosdep if not already done
RUN if [ ! -d /etc/ros/rosdep ]; then rosdep init; fi && rosdep update || true

# Create non-root user matching the host user UID/GID and grant passwordless sudo
RUN if id -u ubuntu >/dev/null 2>&1; then userdel -r ubuntu 2>/dev/null || true; fi && \
    if getent group ubuntu >/dev/null 2>&1; then groupdel ubuntu 2>/dev/null || true; fi && \
    if ! getent group ${USER_GID} >/dev/null 2>&1; then \
        groupadd --gid ${USER_GID} ${USERNAME}; \
    fi && \
    if ! id -u ${USER_UID} >/dev/null 2>&1; then \
        useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME}; \
    fi && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Set up system-wide and user default ~/.tmux.conf
COPY .tmux.conf /etc/tmux.conf
USER ${USERNAME}
WORKDIR /home/${USERNAME}
COPY --chown=${USERNAME}:${USERNAME} .tmux.conf /home/${USERNAME}/.tmux.conf

# Configure ~/.bashrc
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc && \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc && \
    echo 'if [ -f /home/'${USERNAME}'/ros2_ws/install/setup.bash ]; then source /home/'${USERNAME}'/ros2_ws/install/setup.bash; fi' >> ~/.bashrc

# Create workspace directory
RUN mkdir -p /home/${USERNAME}/ros2_ws/src
WORKDIR /home/${USERNAME}/ros2_ws

# Default command starts bash in an interactive shell
CMD ["/bin/bash"]
