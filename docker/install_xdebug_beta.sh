#!/bin/sh
set -e

readonly VERSION=xdebug-2.6.0beta1
readonly SHA=49de661e1e18cbbd739fc9fb7a014a36f97a84d2c4a89417c358dd258340527d
readonly URL=https://xdebug.org/files/${VERSION}.tgz


# Download, validate, and extract
(
    cd /tmp/
    wget "${URL}";
    echo "${SHA}"    "/tmp/${VERSION}.tgz" | sha256sum --check
    tar -xzvf /tmp/${VERSION}.tgz;
)

# Installation steps
(
    cd /tmp/${VERSION}/;
    phpize;
    ./configure --enable-xdebug;
    make clean;
    make;
    make install;
)

# Clean up to avoid image bloat
rm -fr /tmp/${VERSION}/;
