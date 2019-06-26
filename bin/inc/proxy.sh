#!/bin/bash

function buildRunProxy()
{
    if [[ -z "${HOST_PORT}" ]]; then
        echo
        echo 'HOST_PORT was not set, even when attempting to get the proxy set up! Defaulting to 80....'
        echo
        HOST_PORT=80
    fi

    if [[ -z "${HOST_PORT_SSL}" ]]; then
        echo
        echo 'HOST_PORT_SSL was not set, even when attempting to get the proxy set up! Defaulting to 443....'
        echo
        HOST_PORT_SSL=443
    fi

    docker-compose \
        --file "${MYDOCK_ROOT}/utilities/proxy/docker-compose.yml" \
        up \
        -d \
        --force-recreate

    return $?
}