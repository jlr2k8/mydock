#!/bin/bash

function addHost()
{
    local APP_LOCAL_DOMAIN="${1}"

    if [[ -z "${APP_LOCAL_DOMAIN}" ]]; then
        echo
        echo "Fatal - local domain not specified..."

        return 1
    fi


    for i in ${APP_LOCAL_DOMAIN//,/ }; do
      # Check for existing /etc/hosts entry
      ping -c 3 "${i}" > /dev/null 2>&1

      if [[ $? != 0 ]]; then
          echo
          echo "Adding '${i}' as a host entry so it will be accessible as http://${i}:<port>"
          sudo bash -c "echo \"127.0.0.1    ${i}\" >> /etc/hosts"
      fi
    done

    return 1
}