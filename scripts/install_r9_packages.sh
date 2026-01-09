#!/bin/bash

set -eu -o pipefail

cleanup_items=()
cleanup() {
    for item in "${cleanup_items[@]}"; do
        if [[ -e "$item" ]]; then
            rm -rf "$item"
            echo "Removed $item"
        fi
    done
}
trap cleanup EXIT

install_head_node_packages() {
  # `--disablerepo='*'` is obligatory parameter: we can not update repositories in air-gapped environment
  dnf install -y --disablerepo='*' --disableexcludes=kubernetes ./*.rpm
  cp -prv ./helm /usr/local/bin/helm
}

install_software_image_packages() {
  local image_path=$1

  echo "Installing packages to the SoftwareImage $image_path"
  cp -prv packages "$image_path/tmp/"
  cleanup_items+=("$image_path/tmp/packages")
  cm-chroot-sw-img "$image_path" "pushd /tmp/packages && dnf install -y --disablerepo='*' --disableexcludes=kubernetes ./*.rpm"

}

pushd packages || exit 1

install_head_node_packages

popd || exit 1

for i in "$@"; do
  install_software_image_packages "$i"
done
