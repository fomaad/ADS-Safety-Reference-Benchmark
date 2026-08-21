#!/bin/bash
# Script to run Autoware + AWSIM-Labs with proper GPU, display, and DDS forwarding

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
XDG_RUNTIME_DIR=/run/user/$(id -u)

# Create X11 auth file for container
touch $XAUTH
xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# For debug
# echo "Debug Info:"
# echo "  DISPLAY: $DISPLAY"
# echo "  XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
# echo "  User ID: $(id -u)"
# echo ""

docker run \
    --rm -it \
    --gpus all \
    --net=host \
    --ipc=host \
    --cap-add=NET_ADMIN \
    -e DISPLAY=$DISPLAY \
    -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
    -e XAUTHORITY=$XAUTH \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all,graphics,compute \
    -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
    -e CYCLONEDDS_URI=/etc/cyclonedds/cyclonedds.xml \
    -e ROS_DISTRO=humble \
    -e LIBGL_DEBUG=verbose \
    -v $XSOCK:$XSOCK:rw \
    -v $XAUTH:$XAUTH:rw \
    -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
    -v /dev/shm:/dev/shm \
    -v /dev/dri:/dev/dri \
    duongtd23/autoware-awsimlabs:latest /bin/bash

# Cleanup
rm -f $XAUTH

# ros2 launch autoware_launch e2e_simulator.launch.xml vehicle_model:=awsim_labs_vehicle sensor_model:=awsim_labs_sensor_kit map_path:=/autoware_map/nishishinjuku_autoware_map launch_vehicle_interface:=true
