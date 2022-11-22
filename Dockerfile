FROM osrf/ros:noetic-desktop-full

LABEL org.opencontainers.image.description "Docker based ROS 1 drone development environment"

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Install APT packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y git curl sudo ssh python3-genmsg \
    libgstreamer-gl1.0-0 libpulse-mainloop-glib0\
    ros-noetic-mavlink ros-noetic-mavros ros-noetic-mavros-extras \
    libgl1-mesa-glx libgl1-mesa-dri && \
    apt clean

# Install GeographicLib datasets
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh && \
    chmod +x install_geographiclib_datasets.sh && \
    ./install_geographiclib_datasets.sh && \
    rm install_geographiclib_datasets.sh

# Install QGroundControl (app image)
RUN curl https://d176tv9ibo4jno.cloudfront.net/builds/master/QGroundControl.AppImage -o /usr/bin/QGroundControl.AppImage && \
    echo "#!/bin/sh\n/usr/bin/QGroundControl.AppImage --appimage-extract-and-run" > /usr/bin/QGroundControl && \
    chmod +x /usr/bin/QGroundControl.AppImage /usr/bin/QGroundControl

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    echo source /opt/ros/noetic/setup.bash >> /home/${USERNAME}/.bashrc

# Setup px4 ease of use command before dropping into user
RUN  echo "#!/bin/sh\ncd /home/${USERNAME}/PX4-Autopilot && make px4_sitl gazebo" > /usr/bin/px4-gazebo && \
    chmod +x /usr/bin/px4-gazebo

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Download and setup px4 firmware
RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive && \
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh && \
    cd ./PX4-Autopilot && make px4_sitl sitl_gazebo