#!/bin/bash

docker build \
    --tag "${DOCKER_REPO}" \
    "${MYDOCK_ROOT}/projects/${PROJECT}"