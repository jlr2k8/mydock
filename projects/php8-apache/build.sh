#!/bin/bash

if [[ -z "${DOCKER_REPO}" ]]; then
    echo
    echo "Please provide the docker repository name:"
    read -p "Docker Repo: " DOCKER_REPO

    echo "DOCKER_REPO=${DOCKER_REPO}" >> ${ENV}
fi

echo
echo "Checking latest PHP version"
echo

which jq > /dev/null

if [[ $? != 0 ]]; then
  echo "JQ is not installed. Please visit https://stedolan.github.io/jq/download/ and install it"
  echo

  exit
else
  PHP_VERSION=$(curl -s "https://www.php.net/releases/index.php?json&version=8&max=1" | jq "keys[]" | tr -d '"')

  echo "Latest PHP 8: ${PHP_VERSION}"
  echo

  if [[ -z "${PHP_VERSION}" ]]; then
    echo "Could not get the latest PHP version"
    exit
  fi
fi


docker build \
    --tag "${DOCKER_REPO}" \
    --build-arg PHP_VERSION="${PHP_VERSION}" \
    "${MYDOCK_ROOT}/projects/${PROJECT}"