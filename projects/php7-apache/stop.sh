#!/bin/bash

function destroyHelp()
{
    echo "
        Usage: mydock stop <project> [-c] [-i] [-h]

        -c container    Remove associated containers with the ${PROJECT} project
        -i images       Remove associated images with the ${PROJECT} project
        -h help         Provide usage information
    "

    showProjects
    echo

    return 0
}

REMOVE_CONTAINERS=
REMOVE_IMAGES=

while getopts "cih" OPT; do
    case "${OPT}" in
        c)
            echo
            echo "Removing associated ${PROJECT} containers, forcefully..."
            REMOVE_CONTAINERS=true
            ;;
        i)
            echo
            echo "Removing associated ${PROJECT} images, forcefully..."
            REMOVE_IMAGES=true
            ;;
        h|*)
            destroyHelp
            exit 0
            ;;
    esac
done


# Stop container
docker stop "${PROJECT}"

# Remove containers (Adminer will be removed regardless once it's stopped)
if [[ ! -z "${REMOVE_CONTAINERS}" ]]; then
    docker rm "${PROJECT}" --force
fi

# Remove images
if [[ ! -z "${REMOVE_IMAGES}" ]]; then
    docker rmi "${DOCKER_REPO}" --force
fi