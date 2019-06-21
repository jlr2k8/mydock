#!/bin/bash

function createWorkingCopy()
{
    if [[ -z "${WORKING_COPY}" ]]; then
        echo
        echo "Please provide the working copy for your application:"
        read -p "Path: " WORKING_COPY

        if [[ ! -d "${WORKING_COPY}" ]] && [[ ! -z "${WORKING_COPY}" ]]; then
            echo
            echo "'${WORKING_COPY}' is an invalid working copy location! Please try again..."
            createWorkingCopy

            return 1
        else
            echo "WORKING_COPY=${WORKING_COPY}" >> "${ENV}"
        fi
    fi

    . "${ENV}"

    export WORKING_COPY="${WORKING_COPY}"

    return 0
}