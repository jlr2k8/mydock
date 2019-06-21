#!/bin/bash

function getEnv()
{
    local ENV="${1}"

    if [[ -z "${ENV}" ]]; then
        echo
        echo "Fatal - getEnv() requires the environment's name"
        echo

        exit 1
    fi

    if [[ -f "${ENV}" ]]; then
        . "${ENV}"
    else
        echo
        echo "The environment file (${ENV}) does not yet exist... creating now..."
        echo

        touch "${ENV}"
    fi

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