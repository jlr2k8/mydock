#!/bin/bash

function setEnv()
{
    local ENV="${1}"
    local WORKING_COPY="${2}"
    local DOCKER_REPO="${3}"
    local HOST_PORT="${4}"

    if [[ -z "${ENV}" ]]; then
        echo
        echo "Fatal - missing environment filename"
        return 1
    fi

    echo "WORKING_COPY=${WORKING_COPY}" > ${ENV}

    if [[ -z "${DOCKER_REPO}" ]]; then
        echo
        echo "Fatal - Docker repo must be specified"
        return 1
    fi

    echo "DOCKER_REPO=${DOCKER_REPO}" >> ${ENV}
    echo "HOST_PORT=${HOST_PORT}" >> ${ENV}

    return 0
}

function getEnv()
{
    local ENV="${1}"

    if [[ ! -f "${ENV}" ]]; then
        echo
        echo "Please provide the working copy for your application (or skip by leaving blank):"
        read -p "Path: " WORKING_COPY

        if [[ ! -d "${WORKING_COPY}" ]] && [[ ! -z "${WORKING_COPY}" ]]; then
            echo
            echo "'${WORKING_COPY}' is an invalid working copy location! Please try again..."
            getEnv "${ENV}"

            return 1
        fi

        echo
        echo "Please provide the docker repository name:"
        read -p "Docker Repo: " DOCKER_REPO

        echo
        echo "Please provide the host port (or skip by leaving blank):"
        read -p "Host port: " HOST_PORT

        setEnv "${ENV}" "${WORKING_COPY}" "${DOCKER_REPO}" "${HOST_PORT}"
    else
        . ${ENV}
    fi

    export WORKING_COPY="${WORKING_COPY}"
    export DOCKER_REPO="${DOCKER_REPO}"
    export HOST_PORT="${HOST_PORT}"

    return 0
}