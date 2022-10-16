FROM osrf/ros:humble-desktop-full

LABEL org.opencontainers.image.description "Docker based ROS 2 drone development environment"

# User configuration
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Install APT packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y git sudo ssh python3-genmsg libgstreamer-gl1.0-0 && \
    apt clean

# Install Fast-DDS-Gen version 1.0.4
RUN git clone --recursive https://github.com/eProsima/Fast-DDS-Gen.git -b v1.0.4 Fast-RTPS-Gen && \
    cd Fast-RTPS-Gen/gradle/wrapper && \
    sed s/distributionUrl=.*/distributionUrl=https\\:\\/\\/services.gradle.org\\/distributions\\/gradle-6.8.3-bin.zip/g gradle-wrapper.properties && \
    cd ../.. && \
    ./gradlew assemble && \
    env "PATH=$PATH" ./gradlew install && \
    cd .. && \
    rm -rf Fast-RTPS-Gen

# Install QGroundControl (app image)
RUN curl https://d176tv9ibo4jno.cloudfront.net/builds/master/QGroundControl.AppImage -o /usr/bin/QGroundControl.AppImage && \
    echo "#!/bin/sh\n/usr/bin/QGroundControl.AppImage --appimage-extract-and-run" > /usr/bin/QGroundControl && \
    chmod +x /usr/bin/QGroundControl.AppImage /usr/bin/QGroundControl

# Create user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash && \
    # Setup user
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    # Setup ros environment
    echo source /opt/ros/humble/setup.bash >> /home/${USERNAME}/.bashrc

USER dev
WORKDIR /home/${USERNAME}

# Download and build px4 ros bridge
RUN mkdir -p ~/px4_ros_com_ros2/src && \
    git clone https://github.com/PX4/px4_ros_com.git ~/px4_ros_com_ros2/src/px4_ros_com && \
    git clone https://github.com/PX4/px4_msgs.git ~/px4_ros_com_ros2/src/px4_msgs && \
    cd ~/px4_ros_com_ros2/src/px4_ros_com/scripts && \
    ./build_ros2_workspace.bash

# Download and setup px4 firmware
RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive && \
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh

# Setup environment for X11 forwarding
VOLUME [ "/tmp/.X11-unix" ]
ENV DISPLAY=":0"