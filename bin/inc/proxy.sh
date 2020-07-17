#!/bin/bash

function buildRunProxy()
{
    if [[ -z "${HOST_PORT}" ]]; then
        echo
        echo 'Defaulting host port to 80....'
        echo
        HOST_PORT=80
    fi

    if [[ -z "${HOST_PORT_SSL}" ]]; then
        echo
        echo 'Defaulting host SSL port to 443....'
        echo
        HOST_PORT_SSL=443
    fi

    if [[ -z "${HOST_CERT_DIR}" ]]; then
        echo
        echo 'Defaulting cert/key dir to "/usr/local/apache2/ssl"....'
        echo
        HOST_CERT_DIR='/usr/local/apache2/ssl'
    fi

    export HOST_PORT="${HOST_PORT}"
    export HOST_PORT_SSL="${HOST_PORT_SSL}"
    export HOST_CERT_DIR="${HOST_CERT_DIR}"

    docker-compose \
        --file "${MYDOCK_ROOT}/utilities/proxy/docker-compose.yml" \
        up \
        -d \
        --force-recreate

    return $?
}