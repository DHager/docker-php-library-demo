#!/bin/sh
set -eu

readonly PROJECT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
cd "$PROJECT_DIR";
. "bin/config.sh";

if [ -f "$CID_PATH" ]; then
    CID=$(cat "$CID_PATH");

    echo "Stopping container $CID..."
    docker stop --time 5 "$CID" || true ;  # The ||true part makes bash ignore failures for this command

    echo "Removing container $CID..."
    docker rm "$CID" || true ;

    echo "Removing CID file"
    rm "$CID_PATH";
else
    echo "Container doesn't seem to be already running, no CID file found at $PROJECT_DIR/$CID_PATH."
fi;