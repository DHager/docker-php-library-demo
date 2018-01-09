#!/bin/sh
set -eu

readonly PROJECT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
cd "$PROJECT_DIR";

. "bin/config.sh";

if ! [ -f "$CID_PATH" ]; then
   echo "No CID file found, container does not seem to be running.";
   exit 1;
fi;

CID=$(cat "$CID_PATH");
echo "Executing command in container $CID..."
docker exec --interactive \
            --tty \
            "${CID}" \
            bash;

