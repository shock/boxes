#!/bin/bash

# Precompile assets
RAILS_ENV=production bundle exec rake assets:precompile

# Build the Docker image using Buildx
docker buildx build --platform linux/amd64 -t boxes4_ruby_2_6_6:latest --load .