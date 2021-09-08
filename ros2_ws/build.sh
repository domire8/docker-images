#!/bin/bash
ROS_VERSION=foxy
docker pull "ros:${ROS_VERSION}"

IMAGE_NAME=aica-technology/ros2-ws:"${ROS_VERSION}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
if [[ ! -f "${SCRIPT_DIR}"/config/sshd_entrypoint.sh ]]; then
  mkdir -p "${SCRIPT_DIR}"/config
  cp "$(dirname "${SCRIPT_DIR}")"/common/sshd_entrypoint.sh "${SCRIPT_DIR}"/config/ || exit 1
fi

BUILD_FLAGS=()
while getopts 'r' opt; do
  case $opt in
  r) BUILD_FLAGS+=(--no-cache) ;;
  *)
    echo 'Error in command line parsing' >&2
    exit 1
    ;;
  esac
done
shift "$((OPTIND - 1))"

BUILD_FLAGS+=(--build-arg ROS_VERSION="${ROS_VERSION}")

if [[ "$OSTYPE" != "darwin"* ]]; then
  USER_ID="$(id -u "${USER}")"
  GROUP_ID="$(id -g "${USER}")"
  BUILD_FLAGS+=(--build-arg UID="${USER_ID}")
  BUILD_FLAGS+=(--build-arg GID="${GROUP_ID}")
fi

BUILD_FLAGS+=(-t "${IMAGE_NAME}")

DOCKER_BUILDKIT=1 docker build "${BUILD_FLAGS[@]}" .
