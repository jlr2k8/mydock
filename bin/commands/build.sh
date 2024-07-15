#!/bin/bash

function buildHelp()
{
    echo "
        Usage: mydock build [-h] <project>

        -h help     Provide usage information
    "

    showProjects
    echo

    return 0
}

while getopts "h" OPT; do
    case "${OPT}" in
        h|*)
            buildHelp
            exit 0
            ;;
    esac
done

echo
echo "Building ${PROJECT}"

PROJECT_BUILD_FILE="${MYDOCK_ROOT}/projects/${PROJECT}/build.sh"
PROJECT_COMPOSE_FILE="${MYDOCK_ROOT}/projects/${PROJECT}/docker-compose.yml"

if [[ -x "${PROJECT_BUILD_FILE}" ]]; then
    shift 1
    . "${PROJECT_BUILD_FILE}" $@
else
    echo
    echo "Missing build.sh in ${MYDOCK_ROOT}/projects/${PROJECT}"

    exit 1
fi