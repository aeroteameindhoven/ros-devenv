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
    libgl1-mesa-glx libgl1-mesa-dri python3-catkin-tools && \
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

# Add non-root user and allow sudo
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    echo source /opt/ros/noetic/setup.bash >> /home/${USERNAME}/.bashrc

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Download and setup px4 firmware
RUN git clone -n https://github.com/PX4/PX4-Autopilot.git --recursive && \
    cd ./PX4-Autopilot && \
    # Pin to known working commit
    git checkout 5217bedd4b636eba61b55a85a8b3cb61d6b69857 && \
    bash ./Tools/setup/ubuntu.sh && \
    # Pre-build the firmware
    DONT_RUN=1 make px4_sitl_default gazebo

# Setup px4 and ros workspace
COPY --chown=${USERNAME}:${USERNAME} .ros.bashrc .
RUN echo "source ~/.ros.bashrc" >> ~/.bashrc
