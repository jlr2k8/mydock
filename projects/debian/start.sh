#!/bin/bash

docker-compose --file "${PROJECT_COMPOSE_FILE}" \
    up \
    -d \
    --force-recreate