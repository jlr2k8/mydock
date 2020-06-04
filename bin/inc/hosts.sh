#!/bin/bash

function addHost()
{
    local APP_LOCAL_DOMAIN="${1}"

    if [[ -z "${APP_LOCAL_DOMAIN}" ]]; then
        echo
        echo "Fatal - local domain not specified..."

        return 1
    fi

    # Check for existing /etc/hosts entry
    ping -w 3 "${APP_LOCAL_DOMAIN}" > /dev/null 2>&1

    if [[ $? != 0 ]]; then
        echo
        echo "Add '${APP_LOCAL_DOMAIN}' as a host entry so it will be accessible as http://${APP_LOCAL_DOMAIN}:<port>"
        sudo bash -c "echo \"127.0.0.1    ${APP_LOCAL_DOMAIN}\" >> /etc/hosts"

        return $?
    fi

    return 1
}