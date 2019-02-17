#!/bin/bash

# Create network
docker network create mynet > /dev/null 2>&1

# Local domain name
export PROJECT_DOMAIN="${PROJECT}.local"

# Set port here, if not specified in env
if [[ -z "${HOST_PORT}" ]]; then
    HOST_PORT=80
fi

# Start up the proxy
buildRunProxy

# Add hostname
addHost "${PROJECT_DOMAIN}"

docker-compose \
    --file "${PROJECT_COMPOSE_FILE}" \
    up \
    -d \
    --force-recreate