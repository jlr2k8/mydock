#!/bin/bash

if [[ -z "${DOCKER_REPO}" ]]; then
    echo
    echo "Please provide the docker repository name:"
    read -p "Docker Repo: " DOCKER_REPO

    echo "DOCKER_REPO=${DOCKER_REPO}" >> ${ENV}
fi

# NOTE: Apache 2.4.57 (latest as of 2023-08-13) has an issue with PCRE - I even tried upgrading to PCRE3, also tried
# using the OS build instead of compiling... etc. Nothing worked. Somehow between Apache 2.4.52 - 2.4.57, something
# weird is happening. For now, I'm stubbing out the curl command that pulls the latest and hard-coding in the last known
# version number that works.

#APACHE_VERSION=$(curl -s 'https://downloads.apache.org//httpd/CHANGES_2.4' | head -2 | tail -1 | awk {'print $4'})
APACHE_VERSION="2.4.52"

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