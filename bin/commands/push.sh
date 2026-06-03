#!/bin/bash

if [[ -z "${DOCKER_REPO}" ]]; then
    ensureDockerRepo || exit 1
fi

if ! docker image inspect "${DOCKER_REPO}" > /dev/null 2>&1; then
    echo
    echo "No local image found for '${DOCKER_REPO}'."
    echo "Build it first:  ./bin/mydock build ${PROJECT}"
    echo
    exit 1
fi

docker push "${DOCKER_REPO}"