#!/bin/bash

IMAGE_NAME="technofovea/test-image:latest"; # Arbitrary for your project

WEBSERVER_NAME="my-test-server"; # Matching "server" settings in PHPStorm
HOST_NAME="mytest.docker"; # Just the network host-name as seen in container's command-line
CID_PATH="build/running.cid"; # Relative to project, stores CID of running container if any

# Uncomment the following line if autodetection doesn't work and you don't want to manually enter it often
# HOST_IP=192.168.99.1;