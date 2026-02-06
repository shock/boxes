#!/bin/bash

# Build the Docker image using Buildx
# Asset precompilation is now done inside the container during the build
docker buildx build --platform linux/amd64 -t boxes4_ruby_2_6_6:latest --load .