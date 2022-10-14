# Docker ROS2 Development Environment

![GitHub last commit (branch)](https://img.shields.io/github/last-commit/aeroteameindhoven/ros2-devenv/main)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/aeroteameindhoven/ros2-devenv/Docker)
![License](https://img.shields.io/github/license/aeroteameindhoven/ros2-devenv)

[View Container](https://github.com/aeroteameindhoven/ros2-devenv/pkgs/container/ros2-devenv)

## Usage

In the root of your project, add a file
`.devcontainer/devcontainer.json` with the contents:

```json
{
    "name": "ROS 2 Development Environment",
    "image": "ghcr.io/aeroteameindhoven/ros2-devenv:main"
}
```

This will pull the latest build of this docker image from github container registry
for you to develop in
