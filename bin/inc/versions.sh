#!/bin/bash

UPDATE_STATE_FILE="${MYDOCK_ROOT}/var/update-state"

function readDockerfileEnv()
{
    local DOCKERFILE="${1}"
    local KEY="${2}"

    grep -E "^ENV ${KEY}=" "${DOCKERFILE}" 2>/dev/null \
        | head -1 \
        | sed -E "s/^ENV ${KEY}='([^']+)'.*/\1/"

    return 0
}

function readDockerfileFromTag()
{
    local DOCKERFILE="${1}"

    grep -E "^FROM " "${DOCKERFILE}" 2>/dev/null \
        | head -1 \
        | awk '{print $2}'

    return 0
}

function getPinnedDebianVersions()
{
    local DOCKERFILE="${MYDOCK_ROOT}/projects/debian/Dockerfile"

    DEBIAN_PCRE=$(readDockerfileEnv "${DOCKERFILE}" "PCRE_VERSION")
    DEBIAN_OPENSSL=$(readDockerfileEnv "${DOCKERFILE}" "OPENSSL_VERSION")
    DEBIAN_CURL=$(readDockerfileEnv "${DOCKERFILE}" "CURL_VERSION")

    return 0
}

function getPinnedRedisVersion()
{
    REDIS_PINNED=$(readDockerfileEnv "${MYDOCK_ROOT}/projects/redis/Dockerfile" "REDIS_VERSION")

    return 0
}

function getPinnedNodeImage()
{
    NODE_IMAGE=$(readDockerfileFromTag "${MYDOCK_ROOT}/projects/node/web/Dockerfile")

    return 0
}

function fetchLatestApacheVersion()
{
    APACHE_LATEST=$(curl -sf 'https://downloads.apache.org/httpd/CHANGES_2.4' \
        | head -2 \
        | tail -1 \
        | awk '{print $4}')

    return 0
}

function fetchLatestPhp8Version()
{
    if ! command -v jq > /dev/null 2>&1; then
        echo "Fatal - jq is required for PHP version checks"
        return 1
    fi

    PHP8_LATEST=$(curl -sf "https://www.php.net/releases/index.php?json&version=8&max=1" \
        | jq -r 'keys[]' \
        | head -1)

    return 0
}

function fetchLatestRedisVersion()
{
    local MAJOR="${REDIS_PINNED%%.*}"

    if command -v jq > /dev/null 2>&1; then
        REDIS_LATEST=$(curl -sf 'https://api.github.com/repos/redis/redis/releases?per_page=30' \
            | jq -r '.[].tag_name' \
            | sed 's/^v//' \
            | grep -E "^${MAJOR}\\." \
            | head -1)
    else
        REDIS_LATEST=$(curl -sf 'https://download.redis.io/redis-stable/README' \
            | grep -m1 '^redis_version:' \
            | awk '{print $2}')
    fi

    if [[ -z "${REDIS_LATEST}" ]]; then
        REDIS_LATEST="${REDIS_PINNED}"
    fi

    return 0
}

function fetchLatestOpensslVersion()
{
    local MAJOR="${DEBIAN_OPENSSL%%.*}"

    if command -v jq > /dev/null 2>&1; then
        OPENSSL_LATEST=$(curl -sf 'https://api.github.com/repos/openssl/openssl/releases?per_page=30' \
            | jq -r '.[].tag_name' \
            | sed -E 's/^openssl-//' \
            | grep -E "^${MAJOR}\\." \
            | head -1)
    else
        OPENSSL_LATEST=$(curl -sf 'https://www.openssl.org/source/' \
            | grep -oE "openssl-${MAJOR}\\.[0-9]+\\.[0-9]+\\.tar.gz" \
            | head -1 \
            | sed -E "s/openssl-//;s/\\.tar\\.gz//")
    fi

    if [[ -z "${OPENSSL_LATEST}" ]]; then
        OPENSSL_LATEST="${DEBIAN_OPENSSL}"
    fi

    return 0
}

function fetchLatestCurlVersion()
{
    if command -v jq > /dev/null 2>&1; then
        CURL_LATEST=$(curl -sf 'https://api.github.com/repos/curl/curl/releases/latest' \
            | jq -r '.tag_name' \
            | sed -E 's/^curl-//;s/_/./g')
    else
        CURL_LATEST=$(curl -sf 'https://curl.se/download.html' \
            | grep -oE 'curl-[0-9]+\.[0-9]+\.[0-9]+\.tar.bz2' \
            | head -1 \
            | sed -E 's/curl-//;s/\.tar\.bz2//')
    fi

    return 0
}

function fetchLatestPcreVersion()
{
    PCRE_LATEST=$(curl -sf 'https://sourceforge.net/projects/pcre/files/pcre/' \
        | grep -oE 'pcre/[0-9]+\.[0-9]+' \
        | head -1 \
        | sed 's/pcre\///')

    if [[ -z "${PCRE_LATEST}" ]]; then
        PCRE_LATEST="${DEBIAN_PCRE}"
    fi

    return 0
}

function fetchLatestNodeImageDigest()
{
    local TAG="${1}"

    if command -v jq > /dev/null 2>&1; then
        NODE_DIGEST=$(curl -sf "https://hub.docker.com/v2/repositories/library/node/tags/${TAG}" \
            | jq -r '.digest // empty')
    else
        NODE_DIGEST=$(curl -sfI "https://hub.docker.com/v2/repositories/library/node/tags/${TAG}" \
            | grep -i '^etag:' \
            | awk '{print $2}' \
            | tr -d $'\r')
    fi

    return 0
}

function loadUpdateState()
{
    if [[ -f "${UPDATE_STATE_FILE}" ]]; then
        # shellcheck disable=SC1090
        . "${UPDATE_STATE_FILE}"
    fi

    return 0
}

function saveUpdateState()
{
    mkdir -p "$(dirname "${UPDATE_STATE_FILE}")"

    cat > "${UPDATE_STATE_FILE}" <<EOF
LAST_RUN='$(date -Iseconds)'
DEBIAN_PCRE='${DEBIAN_PCRE}'
DEBIAN_OPENSSL='${DEBIAN_OPENSSL}'
DEBIAN_CURL='${DEBIAN_CURL}'
APACHE='${APACHE_PINNED}'
PHP8='${PHP8_PINNED}'
REDIS='${REDIS_PINNED}'
NODE_IMAGE='${NODE_IMAGE}'
NODE_DIGEST='${NODE_DIGEST}'
EOF

    return 0
}

function captureRecordedVersions()
{
    # Apache and PHP versions are fetched from upstream at build time, not
    # pinned in Dockerfiles. On first run, seed recorded values from the
    # live API response so later checks have a baseline to compare against.
    if [[ -z "${APACHE_PINNED}" ]] && [[ -n "${APACHE_LATEST}" ]]; then
        APACHE_PINNED="${APACHE_LATEST}"
    fi

    if [[ -z "${PHP8_PINNED}" ]] && [[ -n "${PHP8_LATEST}" ]]; then
        PHP8_PINNED="${PHP8_LATEST}"
    fi

    return 0
}

function syncRecordedVersionsAfterBuild()
{
    if [[ " ${BUILT_PROJECTS[*]} " == *" apache "* ]] && [[ -n "${APACHE_LATEST}" ]]; then
        APACHE_PINNED="${APACHE_LATEST}"
    fi

    if [[ " ${BUILT_PROJECTS[*]} " == *" php8-apache "* ]] && [[ -n "${PHP8_LATEST}" ]]; then
        PHP8_PINNED="${PHP8_LATEST}"
    fi

    return 0
}

function persistUpdateState()
{
    getPinnedDebianVersions
    getPinnedRedisVersion
    getPinnedNodeImage
    fetchLatestApacheVersion
    fetchLatestPhp8Version
    fetchLatestRedisVersion

    NODE_TAG="${NODE_IMAGE#node:}"
    fetchLatestNodeImageDigest "${NODE_TAG}"

    saveUpdateState

    return 0
}

function updateDockerfileEnv()
{
    local DOCKERFILE="${1}"
    local KEY="${2}"
    local VALUE="${3}"

    sed -i "s|^ENV ${KEY}='.*'|ENV ${KEY}='${VALUE}'|" "${DOCKERFILE}"

    return 0
}

function updateNodeDockerfileFrom()
{
    local DOCKERFILE="${MYDOCK_ROOT}/projects/node/web/Dockerfile"
    local IMAGE="${1}"

    sed -i "s|^FROM .*|FROM ${IMAGE}|" "${DOCKERFILE}"

    NODE_IMAGE="${IMAGE}"

    return 0
}

function checkAllUpdates()
{
    local STATE_FILE_EXISTED=0

    if [[ -f "${UPDATE_STATE_FILE}" ]]; then
        STATE_FILE_EXISTED=1
    fi

    getPinnedDebianVersions
    getPinnedRedisVersion
    getPinnedNodeImage
    loadUpdateState

    APACHE_PINNED="${APACHE:-}"
    PHP8_PINNED="${PHP8:-}"

    fetchLatestApacheVersion
    fetchLatestPhp8Version
    fetchLatestRedisVersion
    fetchLatestOpensslVersion
    fetchLatestCurlVersion
    fetchLatestPcreVersion

    captureRecordedVersions

    NEEDS_DEBIAN=0
    NEEDS_APACHE=0
    NEEDS_PHP8=0
    NEEDS_REDIS=0
    NEEDS_NODE=0
    DEBIAN_PCRE_CHANGED=0
    DEBIAN_OPENSSL_CHANGED=0
    DEBIAN_CURL_CHANGED=0
    APACHE_VERSION_CHANGED=0
    PHP8_VERSION_CHANGED=0
    REDIS_VERSION_CHANGED=0
    APACHE_CASCADE=0
    PHP8_CASCADE=0
    REDIS_CASCADE=0

    if [[ "${DEBIAN_PCRE}" != "${PCRE_LATEST}" ]]; then
        DEBIAN_PCRE_CHANGED=1
    fi

    if [[ "${DEBIAN_OPENSSL}" != "${OPENSSL_LATEST}" ]]; then
        DEBIAN_OPENSSL_CHANGED=1
    fi

    if [[ "${DEBIAN_CURL}" != "${CURL_LATEST}" ]]; then
        DEBIAN_CURL_CHANGED=1
    fi

    if [[ ${DEBIAN_PCRE_CHANGED} -eq 1 ]] \
        || [[ ${DEBIAN_OPENSSL_CHANGED} -eq 1 ]] \
        || [[ ${DEBIAN_CURL_CHANGED} -eq 1 ]]; then
        NEEDS_DEBIAN=1
    fi

    if [[ -n "${APACHE_LATEST}" ]] && [[ "${APACHE_PINNED}" != "${APACHE_LATEST}" ]]; then
        APACHE_VERSION_CHANGED=1
        NEEDS_APACHE=1
    fi

    if [[ -n "${PHP8_LATEST}" ]] && [[ "${PHP8_PINNED}" != "${PHP8_LATEST}" ]]; then
        PHP8_VERSION_CHANGED=1
        NEEDS_PHP8=1
    fi

    if [[ -n "${REDIS_LATEST}" ]] && [[ "${REDIS_PINNED}" != "${REDIS_LATEST}" ]]; then
        REDIS_VERSION_CHANGED=1
        NEEDS_REDIS=1
    fi

    STORED_NODE_DIGEST="${NODE_DIGEST:-}"
    NODE_TAG="${NODE_IMAGE#node:}"
    fetchLatestNodeImageDigest "${NODE_TAG}"

    if [[ -n "${STORED_NODE_DIGEST}" ]] \
        && [[ -n "${NODE_DIGEST}" ]] \
        && [[ "${NODE_DIGEST}" != "${STORED_NODE_DIGEST}" ]]; then
        NEEDS_NODE=1
    fi

    # Cascade: debian rebuild forces downstream images that depend on it
    if [[ ${NEEDS_DEBIAN} -eq 1 ]]; then
        if [[ ${NEEDS_APACHE} -eq 0 ]]; then
            APACHE_CASCADE=1
        fi
        if [[ ${NEEDS_REDIS} -eq 0 ]] && [[ ${REDIS_VERSION_CHANGED} -eq 0 ]]; then
            REDIS_CASCADE=1
        fi
        NEEDS_APACHE=1
        NEEDS_REDIS=1
    fi

    if [[ ${NEEDS_APACHE} -eq 1 ]]; then
        if [[ ${NEEDS_PHP8} -eq 0 ]]; then
            PHP8_CASCADE=1
        fi
        NEEDS_PHP8=1
    fi

    # First run without state: skip version-only rebuilds for apache/php/node,
    # but keep cascade rebuilds when a base image (debian) actually changed.
    if [[ ${STATE_FILE_EXISTED} -eq 0 ]]; then
        NEEDS_NODE=0

        if [[ ${NEEDS_DEBIAN} -eq 0 ]]; then
            NEEDS_APACHE=0
            NEEDS_PHP8=0
            APACHE_CASCADE=0
            PHP8_CASCADE=0
        else
            if [[ ${APACHE_VERSION_CHANGED} -eq 0 ]]; then
                APACHE_CASCADE=1
            fi
            if [[ ${PHP8_VERSION_CHANGED} -eq 0 ]]; then
                PHP8_CASCADE=1
            fi
        fi
    fi

    return 0
}

function applyDebianPinUpdates()
{
    if [[ "${DEBIAN_PCRE}" != "${PCRE_LATEST}" ]]; then
        updateDockerfileEnv "${MYDOCK_ROOT}/projects/debian/Dockerfile" "PCRE_VERSION" "${PCRE_LATEST}"
        DEBIAN_PCRE="${PCRE_LATEST}"
    fi

    if [[ "${DEBIAN_OPENSSL}" != "${OPENSSL_LATEST}" ]]; then
        updateDockerfileEnv "${MYDOCK_ROOT}/projects/debian/Dockerfile" "OPENSSL_VERSION" "${OPENSSL_LATEST}"
        DEBIAN_OPENSSL="${OPENSSL_LATEST}"
    fi

    if [[ "${DEBIAN_CURL}" != "${CURL_LATEST}" ]]; then
        updateDockerfileEnv "${MYDOCK_ROOT}/projects/debian/Dockerfile" "CURL_VERSION" "${CURL_LATEST}"
        DEBIAN_CURL="${CURL_LATEST}"
    fi

    return 0
}

function applyRedisPinUpdate()
{
    if [[ "${REDIS_PINNED}" != "${REDIS_LATEST}" ]]; then
        updateDockerfileEnv "${MYDOCK_ROOT}/projects/redis/Dockerfile" "REDIS_VERSION" "${REDIS_LATEST}"
    fi

    REDIS_PINNED="${REDIS_LATEST}"

    return 0
}

function versionStatusLabel()
{
    local CHANGED="${1}"
    local REBUILD="${2}"
    local CASCADE="${3}"

    if [[ ${CHANGED} -eq 1 ]]; then
        echo '[UPDATE]'
    elif [[ ${REBUILD} -eq 1 ]] && [[ ${CASCADE} -eq 1 ]]; then
        echo '[rebuild - dependency]'
    elif [[ ${REBUILD} -eq 1 ]]; then
        echo '[rebuild]'
    else
        echo '[ok]'
    fi

    return 0
}

function reportUpdateStatus()
{
    local LOG_FN="${1:-echo}"
    local REBUILD_PLAN=""

    ${LOG_FN} "Version check summary (recorded -> latest from upstream):"
    ${LOG_FN} "  debian  PCRE:     ${DEBIAN_PCRE} -> ${PCRE_LATEST} $(versionStatusLabel ${DEBIAN_PCRE_CHANGED} 0 0)"
    ${LOG_FN} "  debian  OpenSSL: ${DEBIAN_OPENSSL} -> ${OPENSSL_LATEST} $(versionStatusLabel ${DEBIAN_OPENSSL_CHANGED} 0 0)"
    ${LOG_FN} "  debian  cURL:    ${DEBIAN_CURL} -> ${CURL_LATEST} $(versionStatusLabel ${DEBIAN_CURL_CHANGED} 0 0)"
    ${LOG_FN} "  apache:          ${APACHE_PINNED} -> ${APACHE_LATEST} $(versionStatusLabel ${APACHE_VERSION_CHANGED} ${NEEDS_APACHE} ${APACHE_CASCADE})"
    ${LOG_FN} "  php8-apache:     ${PHP8_PINNED} -> ${PHP8_LATEST} $(versionStatusLabel ${PHP8_VERSION_CHANGED} ${NEEDS_PHP8} ${PHP8_CASCADE})"
    ${LOG_FN} "  redis:           ${REDIS_PINNED} -> ${REDIS_LATEST} $(versionStatusLabel ${REDIS_VERSION_CHANGED} ${NEEDS_REDIS} ${REDIS_CASCADE})"
    ${LOG_FN} "  node (${NODE_IMAGE}): digest changed=$([[ ${NEEDS_NODE} -eq 1 ]] && echo 'yes' || echo 'no')"

    [[ ${NEEDS_DEBIAN} -eq 1 ]] && REBUILD_PLAN+="debian "
    [[ ${NEEDS_APACHE} -eq 1 ]] && REBUILD_PLAN+="apache "
    [[ ${NEEDS_PHP8} -eq 1 ]] && REBUILD_PLAN+="php8-apache "
    [[ ${NEEDS_REDIS} -eq 1 ]] && REBUILD_PLAN+="redis "
    [[ ${NEEDS_NODE} -eq 1 ]] && REBUILD_PLAN+="node "

    if [[ -n "${REBUILD_PLAN}" ]]; then
        ${LOG_FN} "Rebuild plan: ${REBUILD_PLAN}"
    fi

    return 0
}