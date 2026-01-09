#!/bin/bash

set -eu -o pipefail

readonly DGX_DETECT_PACKAGES=( \
  "dgx-repo"\
  "dgx-release"\
)

readonly DGX_REMOVE=( \
  "containerd"\
  "containerd.io"\
  "nvidia-docker2"\
  "docker-ce-cli"\
)

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
  dpkg --install --force-confdef,confold --no-pager \
    ./packages/*.deb \
    ./packages-non-dgx/*.deb
  cp -prv ./packages/helm /usr/local/bin/helm
}

install_software_image_packages() {
  local image_path=$1
  local dgx
  local package_paths=()

  dgx=$(is_dgx "$image_path")

  echo "Installing packages to the SoftwareImage $image_path"
  cp -prv packages "$image_path/tmp/"
  cleanup_items+=("$image_path/tmp/packages")
  package_paths+=('packages')

  if [[ $dgx = "true" ]]; then
    echo "SoftwareImage \"$image_path\" is a DGX image"
    cleanup_dgx "$image_path"
    cp -prv packages-dgx "$image_path/tmp/"
    cleanup_items+=("$image_path/tmp/packages-dgx")
    # TODO(Aleksei):uncomment in the case of DGX specific packages added
    # package_paths+=('packages-dgx')
  else
    cp -prv packages-non-dgx "$image_path/tmp/"
    cleanup_items+=("$image_path/tmp/packages-non-dgx")
    package_paths+=('packages-non-dgx')
  fi

  for item in "${package_paths[@]}"; do
    cm-chroot-sw-img "$image_path" \
      "pushd /tmp/$item && dpkg --install --force-confdef,confold --no-pager ./*.deb"
  done
}

is_dgx() {
  local image_path=$1

  # shellcheck disable=SC2016,SC2048,SC2086
  cm-chroot "$image_path" \
    dpkg-query -W -f='${binary:Package}\t${Version}\t${Architecture}\t${Status}\n' ${DGX_DETECT_PACKAGES[*]} 2>/dev/null \
    | grep '\sinstalled$' >/dev/null \
    && echo "true" || echo "false"
}

cleanup_dgx() {
  local image_path=$1

  cm-chroot "$image_path" \
    /bin/bash -c "DEBIAN_FRONTEND=noninteractive dpkg --remove --no-pager ${DGX_REMOVE[*]}"
}

airgapped_tmp_packages_dir="$(mktemp -d)"
cleanup_items+=("$airgapped_tmp_packages_dir")

chmod +rx "$airgapped_tmp_packages_dir"

# Copy all
cp -prv packages "$airgapped_tmp_packages_dir/"
cp -prv packages-non-dgx "$airgapped_tmp_packages_dir/"
cp -prv packages-dgx "$airgapped_tmp_packages_dir/"

pushd "$airgapped_tmp_packages_dir" || exit 1
  install_head_node_packages
popd || exit 1

for i in "$@"; do
  install_software_image_packages "$i"
done
