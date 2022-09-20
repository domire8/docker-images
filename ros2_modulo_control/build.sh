#!/bin/bash

IMAGE_NAME=aica-technology/ros2-modulo-control

LOCAL_BASE_IMAGE=false
BASE_IMAGE=ghcr.io/aica-technology/ros2-modulo
BASE_TAG=galactic
OUTPUT_TAG=galactic

BUILD_FLAGS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
  --local-base)
    LOCAL_BASE_IMAGE=true
    shift 1
    ;;
  --base-tag)
    BASE_TAG=$2
    shift 2
    ;;
  --output-tag)
    OUTPUT_TAG=$2
    shift 2
    ;;
  -r | --rebuild)
    BUILD_FLAGS+=(--no-cache)
    shift 1
    ;;
  -v | --verbose)
    BUILD_FLAGS+=(--progress=plain)
    shift 1
    ;;
  *)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
  esac
done

if [ "${LOCAL_BASE_IMAGE}" = true ]; then
  BUILD_FLAGS+=(--build-arg BASE_IMAGE=aica-technology/ros2-modulo)
else
  docker pull "${BASE_IMAGE}:${BASE_TAG}"
fi

BUILD_FLAGS+=(--build-arg BASE_TAG="${BASE_TAG}")
BUILD_FLAGS+=(-t "${IMAGE_NAME}:${OUTPUT_TAG}")

if [[ "${BASE_TAG}" == *"galactic"* ]]; then
  DOCKERFILE=Dockerfile.galactic
else
  DOCKERFILE=Dockerfile.humble
fi

DOCKER_BUILDKIT=1 docker build -f "${DOCKERFILE}" "${BUILD_FLAGS[@]}" .
