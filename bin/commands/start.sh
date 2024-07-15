#!/bin/bash

function startHelp()
{
    echo "
        Usage: mydock start [-h] <project>

        -h help     Provide usage information
    "

    showProjects
    echo

    return 0
}

while getopts "h" OPT; do
    case "${OPT}" in
        h|*)
            startHelp
            exit 0
            ;;
    esac
done

echo
echo "Starting ${PROJECT}"

PROJECT_COMPOSE_FILE="${MYDOCK_ROOT}/projects/${PROJECT}/docker compose.yml"

if [[ ! -e "${PROJECT_COMPOSE_FILE}" ]]; then
    PROJECT_COMPOSE_FILE="${MYDOCK_ROOT}/projects/custom/${PROJECT}/docker compose.yml"
fi

PROJECT_START_FILE="${MYDOCK_ROOT}/projects/${PROJECT}/start.sh"

if [[ ! -e "${PROJECT_START_FILE}" ]]; then
    PROJECT_START_FILE="${MYDOCK_ROOT}/projects/custom/${PROJECT}/start.sh"
fi

if [[ -x "${PROJECT_START_FILE}" ]]; then
    shift 1
    . "${PROJECT_START_FILE}" $@
else
    echo
    echo "Missing start.sh for ${PROJECT}"

    exit 1
fi