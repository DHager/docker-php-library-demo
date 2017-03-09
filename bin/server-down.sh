#!/bin/bash
set -e
PROJECT_DIR=`dirname $(readlink -f '$BASH_SOURCE../')`;
source ${PROJECT_DIR}/bin/config.sh

if [ -f "$PROJECT_DIR/$CID_PATH" ]; then
    CID=$(cat "$PROJECT_DIR/$CID_PATH");

    echo "Stopping container $CID..."
    docker stop --time 5 $CID || true ;  # The ||true part makes bash ignore failures for this command

    echo "Removing container $CID..."
    docker rm $CID || true ;

    echo "Removing CID file"
    rm "$PROJECT_DIR/$CID_PATH";
else
    echo "Container doesn't seem to be already running, no CID file found at $PROJECT_DIR/$CID_PATH."
fi;