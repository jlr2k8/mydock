#!/bin/bash

# Cron-friendly wrapper for automated stack updates.
#
# Example crontab entry (weekly, Sunday 3am):
#   0 3 * * 0 /home/josh/mydock/scripts/cron-update.sh >> /home/josh/mydock/var/logs/cron.log 2>&1

MYDOCK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export MYDOCK_ROOT
export MYDOCK_NONINTERACTIVE=1
export MYDOCK_UPDATE_QUIET=1

exec "${MYDOCK_ROOT}/bin/mydock" update "$@"