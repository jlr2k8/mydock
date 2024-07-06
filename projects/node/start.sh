#!/bin/bash

# Create network
docker network create mynet > /dev/null 2>&1

# Set domain for reverse proxy
if [[ -z "${PROJECT_DOMAIN+set}" ]]; then
    echo
    echo "What is the domain name for this project? (i.e. example.com):"
    read -p "Domain name: " PROJECT_DOMAIN

    setEnvItem PROJECT_DOMAIN "${PROJECT_DOMAIN}"
fi

# Set working copy
if [[ -z "${WORKING_COPY+set}" ]]; then
    echo
    echo "Please provide the working copy"
    read -p "Working copy: " WORKING_COPY

    setEnvItem WORKING_COPY "${WORKING_COPY}"
fi

# Set port here, if not specified in env. For web projects, this is available to set the host port in docker-compose
if [[ -z "${HOST_PORT+set}" ]]; then
    echo
    echo "Please provide the host port (or skip by leaving blank):"
    read -p "Host port: " HOST_PORT

    setEnvItem HOST_PORT "${HOST_PORT}"
fi

# Default to port 80 if left blank
if [[ -z "${HOST_PORT}" ]]; then
    HOST_PORT=80
fi

# Exporting for docker-compose
export WORKING_COPY="${WORKING_COPY}"
export PROJECT_DOMAIN="${PROJECT_DOMAIN}"
export HOST_PORT="${HOST_PORT}"

# Start up the proxy
buildRunProxy

# Add hostname
addHost "${PROJECT_DOMAIN}"

docker-compose \
    --file "${PROJECT_COMPOSE_FILE}" \
    up \
    -d \
    --force-recreate