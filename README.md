# Docker ROS Development Environment

![GitHub last commit (branch)](https://img.shields.io/github/last-commit/aeroteameindhoven/ros-devenv/main)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/aeroteameindhoven/ros-devenv/Docker)
![License](https://img.shields.io/github/license/aeroteameindhoven/ros-devenv)

[View Container](https://github.com/aeroteameindhoven/ros-devenv/pkgs/container/ros-devenv)

## Provided helper commands

-   `QGroundControl` - Extracts and runs QGroundControl
-   `px4-gazebo` - Builds and runs px4 gazebo

## Usage

In the root of your project, add a file
`.devcontainer/devcontainer.json` with the contents:

```json
{
    "name": "ROS Development Environment",
    "image": "ghcr.io/aeroteameindhoven/ros-devenv:main",

    "containerEnv": {
        // X11 Forwarding
        "DISPLAY": "${localEnv:DISPLAY}"
    },

    "mounts": [
        // X11 Forwarding
        "source=/tmp/.X11-unix,target=/tmp/.X11-unix,type=bind",
        // Intel GPU Forwarding
        "source=/dev/dri,target=/dev/dri,type=bind"
    ]
}
```

This will pull the latest build of this docker image from github container registry
for you to develop in
