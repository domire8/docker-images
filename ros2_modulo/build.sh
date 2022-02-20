#!/bin/bash

IMAGE_NAME=aica-technology/ros2-modulo

LOCAL_BASE_IMAGE=false
BASE_IMAGE=ghcr.io/aica-technology/ros2-control-libraries
BASE_TAG=galactic
MODULO_BRANCH=develop

BUILD_FLAGS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
  --local-base)
    LOCAL_BASE_IMAGE=true
    shift 1
    ;;
  --ros-version | --base-tag)
    BASE_TAG=$2
    shift 2
    ;;
  --modulo-branch)
    MODULO_BRANCH=$2
    shift 2
    ;;
  *)
    echo 'Error in command line parsing' >&2
    exit 1
    ;;
  esac
done

if [ "${LOCAL_BASE_IMAGE}" = true ]; then
  BUILD_FLAGS+=(--build-arg BASE_IMAGE=aica-technology/ros2-control-libraries)
else
  docker pull "${BASE_IMAGE}:${BASE_TAG}"
fi

BUILD_FLAGS+=(--build-arg BASE_TAG="${BASE_TAG}")
BUILD_FLAGS+=(--build-arg MODULO_BRANCH="${MODULO_BRANCH}")
BUILD_FLAGS+=(-t "${IMAGE_NAME}:${BASE_TAG}")

DOCKER_BUILDKIT=1 docker build "${BUILD_FLAGS[@]}" .
