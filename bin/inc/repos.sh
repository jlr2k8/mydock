#!/bin/bash

function defaultDockerRepo()
{
    case "${1}" in
        debian)      echo "joshlrogers/debian" ;;
        apache)      echo "joshlrogers/apache" ;;
        php8-apache) echo "joshlrogers/php8-apache" ;;
        redis)       echo "joshlrogers/redis" ;;
        node)        echo "joshlrogers/node" ;;
        *)           echo "" ;;
    esac

    return 0
}

function ensureDockerRepo()
{
    if [[ -n "${DOCKER_REPO}" ]]; then
        return 0
    fi

    DOCKER_REPO=$(defaultDockerRepo "${PROJECT}")

    if [[ -n "${DOCKER_REPO}" ]]; then
        setEnvItem "DOCKER_REPO" "${DOCKER_REPO}"
        return 0
    fi

    if [[ "${MYDOCK_NONINTERACTIVE}" = "1" ]]; then
        echo "Fatal - DOCKER_REPO is not set and no default exists for project '${PROJECT}'"
        return 1
    fi

    echo
    echo "Please provide the docker repository name:"
    read -p "Docker Repo: " DOCKER_REPO

    echo "DOCKER_REPO=${DOCKER_REPO}" >> "${ENV}"

    return 0
}