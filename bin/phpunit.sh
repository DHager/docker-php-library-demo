#!/bin/bash
set -e
PROJECT_DIR=`dirname $(readlink -f '$BASH_SOURCE../')`;
source ${PROJECT_DIR}/bin/config.sh

if ! [ -f "$PROJECT_DIR/$CID_PATH" ]; then
   echo "No CID file found, container does not seem to be running.";
   exit 1;
fi;

CID=$(cat "$PROJECT_DIR/$CID_PATH");
echo "Executing command in container $CID..."
docker exec --interactive \
            --tty \
            ${CID} \
            vendor/bin/phpunit; # See configuration in phpunit.xml