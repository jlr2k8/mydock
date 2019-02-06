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

PROJECT_DESTROY_FILE="${MYDOCK_ROOT}/projects/${PROJECT}/destroy.sh"

if [[ -x "${PROJECT_DESTROY_FILE}" ]]; then
    shift 1
    . "${PROJECT_DESTROY_FILE}" $@
fi