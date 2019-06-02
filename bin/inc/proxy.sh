#!/bin/bash

function buildRunProxy()
{
    docker-compose \
        --file "${MYDOCK_ROOT}/utilities/proxy/docker-compose.yml" \
        up \
        -d \
        --force-recreate

    return $?
}