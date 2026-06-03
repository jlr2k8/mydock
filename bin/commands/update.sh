#!/bin/bash

function updateHelp()
{
    echo "
        Usage: mydock update [-h] [--check] [--push] [--quiet]

        Checks upstream package versions and rebuilds base images in dependency order:
            debian -> apache -> php8-apache -> redis -> node

        Options:
        -h          Show this help
        --check     Report available updates without building
        --push      Push rebuilt images to the registry after a successful build
        --quiet     Log build output to files only (for cron)

        Environment:
        MYDOCK_UPDATE_PUSH=1    Same as --push
        MYDOCK_UPDATE_QUIET=1   Same as --quiet

        Build output streams to the console by default and is also saved under
        var/logs/build-<project>-*.log. Summary lines go to var/logs/update-YYYYMMDD.log
    "

    return 0
}

CHECK_ONLY=0
PUSH_IMAGES=0
QUIET_BUILD=0

while [[ $# -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            updateHelp
            exit 0
            ;;
        --check)
            CHECK_ONLY=1
            shift
            ;;
        --push)
            PUSH_IMAGES=1
            shift
            ;;
        --quiet)
            QUIET_BUILD=1
            shift
            ;;
        *)
            echo "Unknown option: ${1}"
            updateHelp
            exit 1
            ;;
    esac
done

if [[ "${MYDOCK_UPDATE_PUSH}" = "1" ]]; then
    PUSH_IMAGES=1
fi

if [[ "${MYDOCK_UPDATE_QUIET}" = "1" ]]; then
    QUIET_BUILD=1
fi

export MYDOCK_NONINTERACTIVE=1

LOG_DIR="${MYDOCK_ROOT}/var/logs"
LOG_FILE="${LOG_DIR}/update-$(date +%Y%m%d).log"
mkdir -p "${LOG_DIR}"

function updateLog()
{
    local MESSAGE="[$(date -Iseconds)] $*"
    echo "${MESSAGE}" | tee -a "${LOG_FILE}"
    return 0
}

function runProjectBuild()
{
    local BUILD_PROJECT="${1}"
    local PROJECT_BUILD_FILE="${MYDOCK_ROOT}/projects/${BUILD_PROJECT}/build.sh"

    export PROJECT="${BUILD_PROJECT}"
    ENV="${MYDOCK_ROOT}/env/.${BUILD_PROJECT}"

    getEnv "${ENV}"

    if [[ -z "${DOCKER_REPO}" ]]; then
        DOCKER_REPO=$(defaultDockerRepo "${BUILD_PROJECT}")
        if [[ -n "${DOCKER_REPO}" ]]; then
            setEnvItem "DOCKER_REPO" "${DOCKER_REPO}"
        fi
    fi

    if [[ ! -x "${PROJECT_BUILD_FILE}" ]]; then
        updateLog "ERROR - missing build.sh for project '${BUILD_PROJECT}'"
        return 1
    fi

    updateLog "Building ${BUILD_PROJECT} (${DOCKER_REPO})"

    BUILD_LOG="${LOG_DIR}/build-${BUILD_PROJECT}-$(date +%Y%m%d-%H%M%S).log"
    updateLog "Build log: ${BUILD_LOG}"

    # Stream build output to the console and log file together (tee).
    # A separate tail -f would not disrupt the build, but output would interleave
    # messily with status lines — tee keeps one clean stream.
    # shellcheck disable=SC1090
    if [[ ${QUIET_BUILD} -eq 0 ]]; then
        . "${PROJECT_BUILD_FILE}" 2>&1 | tee -a "${BUILD_LOG}"
        BUILD_EXIT=${PIPESTATUS[0]}
    else
        . "${PROJECT_BUILD_FILE}" >> "${BUILD_LOG}" 2>&1
        BUILD_EXIT=$?
    fi

    if [[ ${BUILD_EXIT} -ne 0 ]]; then
        updateLog "ERROR - build failed for ${BUILD_PROJECT} (see ${BUILD_LOG})"
        return 1
    fi

    updateLog "Build succeeded for ${BUILD_PROJECT}"
    return 0
}

function runProjectPush()
{
    local PUSH_PROJECT="${1}"

    export PROJECT="${PUSH_PROJECT}"
    ENV="${MYDOCK_ROOT}/env/.${PUSH_PROJECT}"

    getEnv "${ENV}"

    if [[ -z "${DOCKER_REPO}" ]]; then
        DOCKER_REPO=$(defaultDockerRepo "${PUSH_PROJECT}")
    fi

    updateLog "Pushing ${PUSH_PROJECT} (${DOCKER_REPO})"

    if ! docker push "${DOCKER_REPO}" >> "${LOG_FILE}" 2>&1; then
        updateLog "ERROR - push failed for ${PUSH_PROJECT}"
        return 1
    fi

    updateLog "Push succeeded for ${PUSH_PROJECT}"
    return 0
}

updateLog "=== MyDock update run started ==="

if ! checkAllUpdates; then
    updateLog "ERROR - version check failed"
    exit 1
fi

reportUpdateStatus updateLog

if [[ ${NEEDS_DEBIAN} -eq 0 ]] \
    && [[ ${NEEDS_APACHE} -eq 0 ]] \
    && [[ ${NEEDS_PHP8} -eq 0 ]] \
    && [[ ${NEEDS_REDIS} -eq 0 ]] \
    && [[ ${NEEDS_NODE} -eq 0 ]]; then
    updateLog "All packages are up to date. Nothing to build."
    persistUpdateState

    updateLog "=== MyDock update run finished ==="
    exit 0
fi

if [[ ${CHECK_ONLY} -eq 1 ]]; then
    updateLog "Updates available (--check mode, skipping builds)."
    persistUpdateState
    updateLog "=== MyDock update run finished ==="
    exit 0
fi

BUILT_PROJECTS=()

if [[ ${NEEDS_DEBIAN} -eq 1 ]]; then
    applyDebianPinUpdates
    if runProjectBuild debian; then
        BUILT_PROJECTS+=("debian")
    else
        updateLog "ERROR - aborting update run after debian build failure"
        exit 1
    fi
fi

if [[ ${NEEDS_APACHE} -eq 1 ]]; then
    if runProjectBuild apache; then
        BUILT_PROJECTS+=("apache")
    else
        updateLog "ERROR - aborting update run after apache build failure"
        exit 1
    fi
fi

if [[ ${NEEDS_PHP8} -eq 1 ]]; then
    if runProjectBuild php8-apache; then
        BUILT_PROJECTS+=("php8-apache")
    else
        updateLog "ERROR - aborting update run after php8-apache build failure"
        exit 1
    fi
fi

if [[ ${NEEDS_REDIS} -eq 1 ]]; then
    applyRedisPinUpdate
    if runProjectBuild redis; then
        BUILT_PROJECTS+=("redis")
    else
        updateLog "ERROR - aborting update run after redis build failure"
        exit 1
    fi
fi

if [[ ${NEEDS_NODE} -eq 1 ]]; then
    if runProjectBuild node; then
        BUILT_PROJECTS+=("node")
    else
        updateLog "ERROR - aborting update run after node build failure"
        exit 1
    fi
fi

# Refresh recorded versions for projects that were rebuilt
syncRecordedVersionsAfterBuild
persistUpdateState

updateLog "Rebuilt: ${BUILT_PROJECTS[*]:-none}"

if [[ ${PUSH_IMAGES} -eq 1 ]] && [[ ${#BUILT_PROJECTS[@]} -gt 0 ]]; then
    for BUILT in "${BUILT_PROJECTS[@]}"; do
        if ! runProjectPush "${BUILT}"; then
            updateLog "ERROR - push step failed for ${BUILT}"
            exit 1
        fi
    done
fi

updateLog "=== MyDock update run finished ==="

exit 0