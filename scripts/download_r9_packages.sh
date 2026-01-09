#!/bin/bash

set -eu -o pipefail

ARCH="x86_64"
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
  # This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
  cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v$KUBE_RELEASE/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v$KUBE_RELEASE/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
}

prepare_download() {
  # prepare cache
  sudo dnf makecache || exit 1

  # Install download plugin (if not available)
  sudo dnf install -y 'dnf-command(download)'
}

download_packages() {
  readonly kube_version="$KUBE_RELEASE.$KUBE_PATCH"

  echo "Preparing packages for kubernetes v$kube_version"

  # execute package download
  # use --resolve option for dependencies check against actual image

  # Real requirements
  dnf download --arch noarch,$ARCH --disableexcludes=kubernetes \
    cm-containerd \
    cm-docker \
    cm-docker-registry \
    cm-etcd \
    cm-jupyter-kernel-operator \
    cm-kube-diagnose \
    cm-kubernetes-local-path-provisioner  \
    cm-kubernetes-mpi-operator \
    cm-kubernetes-permissions-manager \
    cm-nvidia-container-toolkit \
    "kubeadm-$kube_version" \
    "kubectl-$kube_version" \
    "kubelet-$kube_version" \
    kubernetes-cni \
    cri-tools \
    conntrack-tools \
    nginx \
    nginx-all-modules \
    python3-netifaces

  # Dependencies
  dnf download --arch noarch,$ARCH --disableexcludes=kubernetes \
    container-selinux \
    libnetfilter_cthelper \
    libnetfilter_cttimeout \
    libnetfilter_queue \
    nginx-core \
    nginx-filesystem \
    nginx-mod-http-image-filter \
    nginx-mod-http-perl \
    nginx-mod-http-xslt-filter \
    nginx-mod-mail \
    nginx-mod-stream \
    system-logos-httpd \
    selinux-policy \
    selinux-policy-targeted
}

download_cuda_packages() {
  # optional BCM cuda related packages (comment out if not needed)
  # use --resolve option for dependencies check against actual image

  # Real requirements
  dnf download --arch noarch,$ARCH \
    cuda-dcgm \
    cuda-fabric-manager \
    cuda-driver

  # Dependencies
  dnf download --arch noarch,$ARCH \
    cuda-dcgm-nvvs
}

copy_helm_binary() {
  # place helm binary here as well, air gapped cluster needs it as well on the Head Node.
  cp -prv /usr/local/bin/helm ./helm
}


mkdir packages
pushd packages || exit 1

handle_kube_release
prepare_repo
prepare_download
download_packages
download_cuda_packages
copy_helm_binary

popd || exit 1
