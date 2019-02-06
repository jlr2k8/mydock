#!/bin/bash

function setEnv()
{
    local ENV="${1}"
    local WORKING_COPY="${2}"
    local DOCKER_REPO="${3}"

    if [[ -z "${ENV}" ]]; then
        echo
        echo "Fatal - missing environment filename"
        return 1
    fi

    echo "WORKING_COPY=${WORKING_COPY}" > ${ENV}

    # Docker repo
    if [[ -z "${DOCKER_REPO}" ]]; then
        echo
        echo "Fatal - Docker repo must be specified for setWorkingCopy()"
        return 1
    fi

    echo "DOCKER_REPO=${DOCKER_REPO}" >> ${ENV}

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

        setEnv "${ENV}" "${WORKING_COPY}" "${DOCKER_REPO}"
    else
        . ${ENV}

        export WORKING_COPY="${WORKING_COPY}"
        export DOCKER_REPO="${DOCKER_REPO}"
    fi

    return 0
}