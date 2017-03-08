#!/bin/bash

IMAGE_NAME="technofovea/test-image"; # Arbitrary for your project
CONTAINER_NAME="my-example-container" # Arbitrary for your project

WEBSERVER_NAME="my-test-server"; # Matching "server" settings in PHPStorm
HOST_NAME="mytest.docker" # Network host-name as seen in container command-line

# Uncomment the following line if autodetection doesn't work and you don't want to manually enter it often
# HOST_IP=192.168.99.1