#!/bin/bash

if [[ -z "${DOCKER_REPO}" ]]; then
    echo
    echo "Please provide the docker repository name:"
    read -p "Docker Repo: " DOCKER_REPO

    echo "DOCKER_REPO=${DOCKER_REPO}" >> ${ENV}
fi

docker build \
    --tag "${DOCKER_REPO}" \
    "${MYDOCK_ROOT}/projects/${PROJECT}"