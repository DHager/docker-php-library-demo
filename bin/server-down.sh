#!/bin/bash
set -e
PROJECT_DIR=`dirname $(readlink -f '$BASH_SOURCE../')`;
source ${PROJECT_DIR}/bin/config.sh

echo "Removing any old running container..."
docker stop ${CONTAINER_NAME};
docker rm ${CONTAINER_NAME};