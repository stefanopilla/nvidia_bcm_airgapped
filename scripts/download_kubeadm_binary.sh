#!/usr/bin/env bash
set -eu -o pipefail

ARCH="amd64"
KUBE_VERSION=""

for i in "$@"; do
  case $i in
    --kube-version=*)
      KUBE_VERSION="${i#*=}"
      ;;
    -h|--help)
      echo "Use $0 to pull kubeadm for air-gapped cm-kubernetes-setup preparation."
      echo "Kube full version should be selected by option '--kube-version=<version>'."
      echo "Kube version selection is done without patch and should be consistent with packages to install."
      exit 0
      ;;
    *)
      echo "Unknown option $i"
      exit 1
      ;;
  esac
done

check_kube_version() {
  if ! [ "$KUBE_VERSION" ]; then
    echo "Kube version is not specified" >&2
    exit 1
  elif [[ ! "$KUBE_VERSION" =~ ^[0-9]+.[0-9]+.[0-9]+$ ]]; then
    echo "Kube version is not valid: '$KUBE_VERSION'" >&2
    exit 1
  fi
}

download_kubeadm() {
  wget "https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/${ARCH}/kubeadm"
  chmod +x kubeadm
  mv kubeadm /usr/bin/
}

check_kube_version

pushd /tmp
  download_kubeadm
popd
