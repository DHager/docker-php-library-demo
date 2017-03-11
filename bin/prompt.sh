#!/bin/bash
set -e

PROJECT_DIR=`dirname $(readlink -f '$BASH_SOURCE../')`;
pushd $PROJECT_DIR > /dev/null;
source "bin/config.sh";

if ! [ -f "$CID_PATH" ]; then
   echo "No CID file found, container does not seem to be running.";
   exit 1;
fi;

CID=$(cat "$CID_PATH");
echo "Executing command in container $CID..."
docker exec --interactive \
            --tty \
            ${CID} \
            bash;

popd > /dev/null;