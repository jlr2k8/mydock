#!/bin/bash

function buildRunAdminer()
{
    addHost adminer.local

    docker compose --file "${MYDOCK_ROOT}/utilities/adminer/docker-compose.yml" \
        up \
        -d \
        --force-recreate

    return $?
}