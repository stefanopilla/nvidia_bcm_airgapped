#!/bin/bash

set -eu -o pipefail

HELM_VERSION="3.18.3"

pushd /tmp
wget "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz"
tar -zxvf "helm-v$HELM_VERSION-linux-amd64.tar.gz"
mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64
popd
