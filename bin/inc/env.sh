#!/bin/bash

function getEnv()
{
    local ENV="${1}"

    if [[ -f "${ENV}" ]]; then
        . ${ENV}
    else
        echo
        echo "The environment file (${ENV}) does not yet exist..."
        echo
    fi

    # Not required - used for projects where the code is actively worked on and evaluated in real-time
    if [[ -z "${WORKING_COPY+set}" ]]; then
        echo
        echo "Please provide the working copy for your application (or skip by leaving blank):"
        read -p "Path: " WORKING_COPY

        if [[ ! -d "${WORKING_COPY}" ]] && [[ ! -z "${WORKING_COPY}" ]]; then
            echo
            echo "'${WORKING_COPY}' is an invalid working copy location! Please try again..."
            getEnv "${ENV}"

            return 1
        else
            echo "WORKING_COPY=${WORKING_COPY}" >> ${ENV}
        fi
    fi

    . ${ENV}

    export WORKING_COPY="${WORKING_COPY}"
    export DOCKER_REPO="${DOCKER_REPO}"

    return 0
}

function setEnvItem()
{
    local KEY="${1}"
    local VALUE="${2}"

    if [[ $# != 2 ]]; then
        echo
        echo "Fatal - this function requires two arguments: <KEY> <VALUE>"
        echo

        return 1
    fi

    # Let's source environment file, just in case
    . ${ENV}

    if [[ -z $(grep "${KEY}=*" ${ENV}) ]]; then
        echo
        echo "Adding new entry for '${KEY}': ${VALUE}"
        echo

        echo "${KEY}='${VALUE}'" >> ${ENV}
    else
        echo
        echo "Replacing existing entry for '${KEY}'..."
        echo

        sed -i "s/${KEY}=.*/${KEY}='${VALUE}'/g" ${ENV}
    fi

    # Refresh the runtime with the newly added env variables by sourcing again
    . ${ENV}

    return 0
}