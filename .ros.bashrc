# Gazebo and PX4 configuration (edit in Dockerfile)
USERNAME="dev"
PX4_PATH="/home/${USERNAME}/PX4-Autopilot"

source $PX4_PATH/Tools/simulation/gazebo/setup_gazebo.bash ${PX4_PATH} ${PX4_PATH}/build/px4_sitl_default
export ROS_PACKAGE_PATH=:$ROS_PACKAGE_PATH:/home/dev/PX4-Autopilot:/home/${USERNAME}/PX4-Autopilot/Tools/simulation/gazebo/sitl_gazebo

# May fail if user has not setup workspace setup
source /home/${USERNAME}/workspace/drone/devel/setup.bash || echo "Your workspace is missing devel/setup.bash. Make sure to run `catkin build`"
