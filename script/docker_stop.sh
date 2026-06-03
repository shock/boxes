#!/bin/bash

# Gracefully stop and remove the boxes4 Docker container

CONTAINER=boxes4_ruby_2_6_6

if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
  echo "Container '${CONTAINER}' is not running."
  exit 0
fi

echo "Stopping container '${CONTAINER}'..."
docker stop "$CONTAINER"

echo "Removing container '${CONTAINER}'..."
docker rm "$CONTAINER"

echo "Done."
