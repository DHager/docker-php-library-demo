#!/bin/bash
set -e
PROJECT_DIR=`dirname $(readlink -f '$BASH_SOURCE../')`;
source ${PROJECT_DIR}/bin/config.sh

echo "Executing command in container ${CONTAINER_NAME}..."
docker exec --interactive \
            --tty \
            ${CONTAINER_NAME} \
            bash;