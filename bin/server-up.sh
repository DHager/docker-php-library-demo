#!/bin/sh
set -eu

readonly PROJECT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
cd "$PROJECT_DIR";
source "bin/config.sh";

# If it seems we're already running, try to stop and cleanup.
if [ -f "$CID_PATH" ]; then
   CID=$(cat "$CID_PATH");
   echo "CID file found, container ($CID) appears to already be running."
   exit 1;
fi;


(echo "$HOST_IP" | grep -Eq '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+') || {
    if [ -x "$(command -v docker-machine)" ]; then
        HOST_IP=$(docker-machine ip default);
        echo "Autodetected IP from docker-machine as $HOST_IP";
    elif [ -x "$(command -v ifconfig)" ]; then
        HOST_IP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1);
        echo "Autodetected IP from ifconfig as $HOST_IP";
    else
        # Prompt, user might be on a windows machine too
        echo "IDE/host IP not in config.sh, and autodetection failed. Please enter it now. (ex: 192.168.99.1)"
        read -r HOST_IP
    fi;
}

# A best-practice for docker is that your "build context" contains the bare-minimum of files you might want to send over
# and bake into your image at build-time. Since we don't really want anything, we use the docker/ subfolder to speed
# things up -- the rest of our stuff is handled as a volume mount later on.
echo "Building docker image..."
docker build --tag ${IMAGE_NAME} \
             --file "docker/Dockerfile" \
             docker/ ;


mkdir --parents ./build/composer-cache/;
mkdir --parents "$(dirname $CID_PATH)";

# Here we run the image (creating a container) in the background, mounting the project directory as writable on /var/php
#
# We use the XDEBUG_CONFIG environment variable here because the IP address of the host machine isn't something we want
# to "bake" into the image.
# The COMPOSER_CACHE_DIR bit is optional, but makes some composer tasks faster because we can keep and reuse our
# downloaded files across containers.
#
# Finally, the "tail" command at the end is just a little trick to make sure the container we launch stays alive in the
# background so that we can use "docker exec" on it later.
echo "Running temporary container for image in background..."
docker run --cidfile "$CID_PATH" \
           --detach \
           --hostname "${HOST_NAME}" \
           --volume "${PROJECT_DIR}:/var/php/" \
           --env COMPOSER_CACHE_DIR="/var/php/build/composer-cache" \
           --env XDEBUG_CONFIG="idekey=$WEBSERVER_NAME remote_host=$HOST_IP remote_autostart=on" \
           --env PHP_IDE_CONFIG="serverName=$WEBSERVER_NAME" \
           "${IMAGE_NAME}" \
           tail -f /dev/null;

CID=$(cat "$CID_PATH");

if [ ! -d "vendor" ]; then
  echo "No vendor directory found, forcing a composer-install to prepare..."
  docker exec --interactive \
              --tty \
              "${CID}" \
              composer install;
fi

echo "Done."