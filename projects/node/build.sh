#!/bin/bash

if [[ -z "${DOCKER_REPO}" ]]; then
    ensureDockerRepo || exit 1
fi

docker build \
    --tag "${DOCKER_REPO}" \
    "${MYDOCK_ROOT}/projects/${PROJECT}/web"