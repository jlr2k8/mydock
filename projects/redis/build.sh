#!/bin/bash

REDIS_PORT='6379'
REDIS_CONFIG_FILE='/etc/redis/6379.conf'
REDIS_LOG_FILE='/var/log/redis_6379.log'
REDIS_DATA_DIR='/var/lib/redis/6379'
REDIS_EXECUTABLE='command -v redis-server'

docker build \
    --build-arg ECR_REPOSITORY="${ECR_REPOSITORY}" \
    --build-arg REDIS_PORT="${REDIS_PORT}" \
    --build-arg REDIS_CONFIG_FILE="${REDIS_CONFIG_FILE}" \
    --build-arg REDIS_LOG_FILE="${REDIS_LOG_FILE}" \
    --build-arg REDIS_DATA_DIR="${REDIS_DATA_DIR}" \
    --build-arg REDIS_EXECUTABLE="${REDIS_EXECUTABLE}" \
    --tag "${DOCKER_REPO}" \
    "${MYDOCK_ROOT}/projects/${PROJECT}"