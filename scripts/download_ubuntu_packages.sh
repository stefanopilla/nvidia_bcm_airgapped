#!/bin/bash

set -eu -o pipefail

# ARCH="x86_64"
# Kube version for packages download & install
# These versions should match kc.version in cm-setup & images versions
KUBE_RELEASE="1.32"
KUBE_PATCH="9"

for i in "$@"; do
  case $i in
    --kube-version=*)
      KUBE_RELEASE="${i#*=}"
      ;;
    -h|--help)
      echo "Use $0 to pull images for air-gapped cm-kubernetes-setup."
      echo "Kube version can be selected by option '--kube-version=<version>'. Default is '$KUBE_RELEASE'."
      echo "Kube version selection is done without patch and should be consistent with the container images."
      exit 0
      ;;
    *)
      echo "Unknown option $i"
      exit 1
      ;;
  esac
done

handle_kube_release() {
  case $KUBE_RELEASE in
  "1.32")
    KUBE_PATCH=9
    ;;
  "1.33")
    KUBE_PATCH=5
    ;;
  "1.34")
    KUBE_PATCH=1
    ;;
  *)
    echo "Not supported kube version: '$KUBE_RELEASE'"
    exit 1
    ;;
  esac
}

prepare_repo() {
  # setup Kubernetes sources list file and key
  echo Setting up Kubernetes sources.list.d file and key...
  cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBE_RELEASE/deb/ /
EOF

  curl -fsSL "https://pkgs.k8s.io/core:/stable:/v$KUBE_RELEASE/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
}

prepare_download() {
  # execute package download
  apt update || exit 1
}

download_packages() {
  readonly kube_version="$KUBE_RELEASE.$KUBE_PATCH"

  echo "Preparing packages for kubernetes v$kube_version"

  apt download -y \
    cm-containerd \
    cm-etcd \
    cm-docker-registry \
    cm-docker \
    cm-kube-diagnose \
    cm-kubernetes-local-path-provisioner  \
    cm-kubernetes-permissions-manager \
    cm-jupyter-kernel-operator \
    cm-kubernetes-mpi-operator \
    "kubeadm=$kube_version-1.1" \
    "kubectl=$kube_version-1.1" \
    "kubelet=$kube_version-1.1" \
    kubernetes-cni \
    cri-tools \
    conntrack \
    nginx \
    ebtables \
    libnginx-mod-http-geoip2 \
    libnginx-mod-http-image-filter \
    libnginx-mod-http-xslt-filter \
    libnginx-mod-mail \
    libnginx-mod-stream \
    libnginx-mod-stream-geoip2 \
    nginx-common \
    nginx-core
}

download_packages_non_dgx() {
  # conflict with DGX
  apt download -y \
    cm-nvidia-container-toolkit
}

download_packages_cuda() {
  # optional BCM cuda related packages (comment out if not needed)
  apt download -y \
  cuda-dcgm \
  cuda-driver \
  cuda-fabric-manager \
  nvidia-modprobe
}

copy_helm_binary() {
  # place helm binary here as well, air gapped cluster needs it as well on the Head Node.
  cp -prv /usr/local/bin/helm ./helm
}


mkdir packages
mkdir packages-non-dgx
mkdir packages-dgx

handle_kube_release
prepare_repo
prepare_download

pushd packages || exit 1
download_packages
copy_helm_binary
popd || exit 1

pushd packages-non-dgx || exit 1
download_packages_non_dgx
download_packages_cuda
popd || exit 1
