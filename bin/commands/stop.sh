#!/bin/bash

function stopHelp()
{
    echo "
        Usage: mydock stop [-h] <project>

        -h help     Provide usage information
    "

    showProjects
    echo

    return 0
}

while getopts "h" OPT; do
    case "${OPT}" in
        h|*)
            stopHelp
            exit 0
            ;;
    esac
done

PROJECT_DESTROY_FILE="${MYDOCK_ROOT}/projects/${PROJECT}/stop.sh"

if [[ -x "${PROJECT_DESTROY_FILE}" ]]; then
    shift 1
    . "${PROJECT_DESTROY_FILE}" $@
else
    echo
    echo "This project does not appear to have an official stop script (${PROJECT_DESTROY_FILE}. Attempting 'docker stop ${PROJECT_NAME}'"
    echo
    docker stop ${PROJECT_NAME}

    if [[ $? != 0 ]]; then
        echo
        echo "Hrm.... well, here is the list of running containers. You'll have to manually run 'docker stop' against whatever containers are running for this project."
        echo
        docker ps
        echo
    fi
fi