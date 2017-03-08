#!/bin/bash
set -e

# $0 isn't as reliable, script may have been launched as "bash foo.sh" instead.
PROJECT_DIR=`dirname $(readlink -f '$BASH_SOURCE../')`;
echo "Project directory absolute path: $PROJECT_DIR"

echo "Loading config"
source ${PROJECT_DIR}/bin/config.sh


if [[ -z "$HOST_IP" ]] || ! [[ "$HOST_IP" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then

    if [ -x "$(command -v ifconfig)" ]; then
        HOST_IP=`ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`;
        echo "Autodetected IP As $HOST_IP";
    else
        # Prompt, user might be on a windows machine too
        echo "IDE/host IP not in config.sh, and autodetection failed. Please enter it now. (ex: 192.168.99.1)"
        read HOST_IP
    fi;
fi;


echo "Creating temporary composer-cache volume..."
docker volume create --name composer-cache


# A best-practice for docker is that your "build context" contains the bare-minimum of files you might want to send over
# and bake into your image at build-time. Since we don't really want anything, we use the docker/ subfolder to speed
# things up -- the rest of our stuff is handled as a volume mount later on.
echo "Building docker image..."
docker build -t ${IMAGE_NAME} -f "docker/Dockerfile" docker/ ;

echo "Removing any old running container..."
docker stop ${CONTAINER_NAME} || true ;
docker rm ${CONTAINER_NAME} || true ;

# Here you can see two volumes being mounted, the current project (with all the src/ and test/ files) and another
# "named" volume which is just an easy way to avoid hammering composer-downloads too much.
#
# We use the XDEBUG_CONFIG environment variable here because the IP address of the host machine isn't something we want
# to "bake" into the image.
#
# Finally, the "tail" command at the end is just a little trick to make sure the container we launch stays alive in the
# background so that we can use "docker exec" on it later.
echo "Running temporary container for image in background..."
docker run --name "${CONTAINER_NAME}" \
           -d \
           -h ${HOST_NAME} \
           -v ${PROJECT_DIR}:/var/php/ \
           -v composer-cache:/root/.composer \
           -e XDEBUG_CONFIG="idekey=docker-phpunit remote_host=$HOST_IP remote_autostart=on" \
           -e PHP_IDE_CONFIG="serverName=$WEBSERVER_NAME" \
           "${IMAGE_NAME}" \
           tail -f /dev/null;

if [ ! -d "$PROJECT_DIR/vendor" ]; then
  echo "No vendor directory found, forcing a composer-install to prepare..."
  docker exec -i -t ${CONTAINER_NAME} composer install;
fi

echo "Done."