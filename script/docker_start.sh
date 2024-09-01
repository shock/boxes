#!/bin/bash

# Source the .env file in the directory above the directory this script is in
DIR=$(dirname "$0")

# Example DATABASE_URL:
# DATABASE_URL=postgres://username:password@host.docker.internal:5432/database_name

docker stop boxes4_ruby_2_6_6
docker rm boxes4_ruby_2_6_6

docker run -d -p 3000:3000 \
  --env-file "$DIR/../.env" \
  -v $(pwd):/app \
  --platform linux/amd64 \
  --name boxes4_ruby_2_6_6 \
  boxes4_ruby_2_6_6
