#!/bin/bash

# Create network
docker network create mynet > /dev/null 2>&1

# Local domain name
export PROJECT_DOMAIN="${PROJECT}.local"

# Start up the proxy
buildRunProxy

# Add hostname
addHost "${PROJECT_LOCAL_DOMAIN}"

docker-compose \
    --file "${PROJECT_COMPOSE_FILE}" \
    up \
    -d