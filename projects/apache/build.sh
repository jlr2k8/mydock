#!/bin/bash

if [[ -z "${DOCKER_REPO}" ]]; then
    ensureDockerRepo || exit 1
fi

APACHE_VERSION=$(curl -s 'https://downloads.apache.org//httpd/CHANGES_2.4' | head -2 | tail -1 | awk {'print $4'})

echo "(sorta) Latest Apache 2.4: ${APACHE_VERSION}"
echo

if [[ -z "${APACHE_VERSION}" ]]; then
  echo "Could not get the latest Apache version"
  exit
fi

docker build \
    --tag "${DOCKER_REPO}" \
    --build-arg APACHE_VERSION="${APACHE_VERSION}" \
    "${MYDOCK_ROOT}/projects/${PROJECT}"