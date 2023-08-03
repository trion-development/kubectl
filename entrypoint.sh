#!/usr/bin/env bash

set -e

INIT_FILE=/app/initialized

if [ ! -f ${INIT_FILE} ]; then
    /app/init.sh
    touch ${INIT_FILE}
fi

if [ -z "$1" ]; then
  exec /bin/bash
else
  exec "$@"
fi
