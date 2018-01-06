#!/usr/bin/bash
set -e

readonly VERSION=xdebug-2.6.0beta1
readonly SHA=49de661e1e18cbbd739fc9fb7a014a36f97a84d2c4a89417c358dd258340527d
readonly URL=https://xdebug.org/files/${VERSION}.tgz


pushd /tmp/;
wget "${URL}";
#if [ $(sha256sum /tmp/${VERSION}.tgz) != ${SHA} ]; then
#    echo "Xdebug source code SHA256 does not match";
#    exit 1;
#fi
tar -xzvf /tmp/${VERSION}.tgz;
cd ./${VERSION}/;

phpize;
./configure --enable-xdebug;
make clean;
make;
make install;

# Cleanup to avoid Docker image bloat
popd
rm -fr /tmp/${VERSION}/;
