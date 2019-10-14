#!/bin/bash

function destroyHelp()
{
    echo "
        Usage: mydock stop <project> [-c] [-i] [-h]

        -c container    Remove associated containers with the ${PROJECT} project
        -i images       Remove associated images with the ${PROJECT} project
        -v volume       Remove associated volumes with the ${PROJECT} project
        -h help         Provide usage information
    "

    showProjects
    echo

    return 0
}

REMOVE_CONTAINERS=
REMOVE_IMAGES=
REMOVE_VOLUMES=

while getopts "civh" OPT; do
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
        v)
            echo
            echo "Removing associated ${PROJECT} volumes, forcefully..."
            REMOVE_VOLUMES=true
            ;;
        h|*)
            destroyHelp
            exit 0
            ;;
    esac
done

# Stop containers
docker stop "${PROJECT}-web"
docker stop "${PROJECT}-db"

# Remove containers (Adminer will be removed regardless once it's stopped)
if [[ ! -z "${REMOVE_CONTAINERS}" ]]; then
    docker rm "${PROJECT}-web" --force
    docker rm "${PROJECT}-db" --force
fi

# Remove db image
if [[ ! -z "${REMOVE_IMAGES}" ]]; then
    docker rmi "${PROJECT}_db" --force
fi

# Remove db volume
if [[ ! -z "${REMOVE_VOLUMES}" ]]; then
    docker volume rm "${PROJECT}_data" --force
fi