#!/bin/bash

IMAGE_NAME=aica-technology/ros2-control-libraries

LOCAL_BASE_IMAGE=false
BASE_IMAGE=ghcr.io/aica-technology/ros2-control
BASE_TAG=humble
OUTPUT_TAG=""
CL_BRANCH=main

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
  --cl-branch)
    CL_BRANCH=$2
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

if [ -z "${OUTPUT_TAG}" ]; then
  echo "Output tag is empty, using the base tag as output tag."
  OUTPUT_TAG="${BASE_TAG}"
fi

if [ "${LOCAL_BASE_IMAGE}" == true ]; then
  BUILD_FLAGS+=(--build-arg BASE_IMAGE=aica-technology/ros2-control)
else
  docker pull "${BASE_IMAGE}:${BASE_TAG}"
fi

if [[ "${BASE_TAG}" == *"galactic"* ]]; then
  UBUNTU_VERSION=focal-fossa
elif [[ "${BASE_TAG}" == *"humble"* ]]; then
  UBUNTU_VERSION=jammy-jellyfish
else
  echo "Invalid base tag. Base tag needs to contain either 'galactic' or 'humble'."
  exit 1
fi

BUILD_FLAGS+=(--build-arg BASE_TAG="${BASE_TAG}")
BUILD_FLAGS+=(--build-arg UBUNTU_VERSION="${UBUNTU_VERSION}")
BUILD_FLAGS+=(--build-arg CL_BRANCH="${CL_BRANCH}")
BUILD_FLAGS+=(-t "${IMAGE_NAME}:${OUTPUT_TAG}")

DOCKER_BUILDKIT=1 docker build "${BUILD_FLAGS[@]}" .
