#!/bin/bash

# Create network
docker network create mynet > /dev/null 2>&1

# Start up the proxy
buildRunProxy

# Add hostname
addHost "${PROJECT_LOCAL_DOMAIN}"

docker compose \
    --file "${PROJECT_COMPOSE_FILE}" \
    up \
    -d \
    --force-recreate