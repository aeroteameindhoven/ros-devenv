FROM osrf/ros:humble-desktop-full

LABEL org.opencontainers.image.description "Docker based ROS 2 drone development environment"

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -y git sudo ssh python3-pip libgstreamer-gl1.0-0 && \
    apt clean

RUN git clone --recursive https://github.com/eProsima/Fast-DDS-Gen.git -b v1.0.4 Fast-RTPS-Gen && \
    cd Fast-RTPS-Gen/gradle/wrapper && \
    sed s/distributionUrl=.*/distributionUrl=https\\:\\/\\/services.gradle.org\\/distributions\\/gradle-6.8.3-bin.zip/g gradle-wrapper.properties && \
    cd ../.. && \
    ./gradlew assemble && \
    env "PATH=$PATH" ./gradlew install && \
    rm -rf Fast-RTPS-Gen

RUN pip install -U pyros-genmsg


RUN wget https://d176tv9ibo4jno.cloudfront.net/builds/master/QGroundControl.AppImage -o /usr/bin/QGroundControl.AppImage && \
    chmod +x /usr/bin/QGroundControl.AppImage && \
    echo -e "#!/bin/sh\n$(pwd)/QGroundControl.AppImage --appimage-extract-and-run" > /usr/bin/QGroundControl

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

RUN mkdir -p ~/px4_ros_com_ros2/src && \
    git clone https://github.com/PX4/px4_ros_com.git ~/px4_ros_com_ros2/src/px4_ros_com && \
    git clone https://github.com/PX4/px4_msgs.git ~/px4_ros_com_ros2/src/px4_msgs && \
    cd ~/px4_ros_com_ros2/src/px4_ros_com/scripts && \
    ./build_ros2_workspace.bash

RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive && \
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh

VOLUME [ "/tmp/.X11-unix" ]
ENV DISPLAY=":0"