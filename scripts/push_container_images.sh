#!/usr/bin/env bash
# This is a CC modified version
set -euo pipefail

KUBE_VERSION="1.31"
registry="master.cm.cluster:5000"
registry_user=""
registry_password=""
module_loaded=false
docker_logged_in=false

for i in "$@"; do
  case $i in
    --kube-version=*)
      KUBE_VERSION="${i#*=}"
      ;;
    -r=*|--registry=*)
      registry="${i#*=}"
      shift # past argument=value
      ;;
    -u=*|--username=*)
      registry_user="${i#*=}"
      shift # past argument=value
      ;;
    -p=*|--password=*)
      registry_password="${i#*=}"
      shift # past argument=value
      ;;
    -h|--help)
      echo "Use $0 -r=<registry> to push prepared images to registry."
      echo "Default registry is '$registry'."
      echo "Kube version can be selected by option '--kube-version=<version>'. Default is '$KUBE_VERSION'."
      echo "Kube version selection is done without patch and should be consistent"
      echo "with downloaded images and packages to install."
      echo "Use options '-u=<username> -p=<password>' for docker login if required."
      exit 0
      ;;
    *)
      echo "Unknown option $i"
      exit 1
      ;;
  esac
done

prepare_docker() {
  if ! command -v "docker" &> /dev/null; then
    if [ -f "/etc/profile.d/modules.sh" ]; then
      # shellcheck disable=SC1091
      . /etc/profile.d/modules.sh
    else
      echo "'/etc/profile.d/modules.sh' not found. Cannot load docker module"
      exit 1
    fi
    module load docker
    module_loaded=true
  fi

  if [ -n "$registry_user" ] && [ -n "$registry_password" ]; then
    docker login "$registry" -u "$registry_user" -p "$registry_password"
    docker_logged_in=true
  elif [ -n "$registry_user" ] || [ -n "$registry_password" ]; then
    echo "Incomplete registry credentials provided"
    exit 1
  fi
}

logout_docker() {
  if [ $docker_logged_in = true ]; then
    docker logout "$registry"
  fi

  if [ $module_loaded = true ]; then
    module unload docker
  fi
}
trap logout_docker EXIT

load_images() {
  echo "Loading images from archives. This can take a while..."

  for archive in *.tar; do
    echo
    echo "Loading '$archive' ..."
    docker load -i "$archive"
  done
}

push_kubeadm_images() {
  case $KUBE_VERSION in
  "1.32")
    push_kubeadm_1_32_images
    ;;
  "1.33")
    push_kubeadm_1_33_images
    ;;
  *)
    echo "Not supported kube version: '$KUBE_VERSION'"
    exit 1
    ;;
  esac
}

push_kubeadm_1_32_images() {
  echo
  echo "Pushing kubeadm Kubernetes 1.32.9 images to the $registry"

  docker tag \
    "registry.k8s.io/coredns/coredns:v1.11.3" \
    "$registry/coredns/coredns:v1.11.3"
  docker push "$registry/coredns/coredns:v1.11.3"
  docker tag \
    "registry.k8s.io/etcd:3.5.16-0" \
    "$registry/etcd:3.5.16-0"
  docker push "$registry/etcd:3.5.16-0"
  docker tag \
    "registry.k8s.io/kube-apiserver:v1.32.9" \
    "$registry/kube-apiserver:v1.32.9"
  docker push "$registry/kube-apiserver:v1.32.9"
  docker tag \
    "registry.k8s.io/kube-controller-manager:v1.32.9" \
    "$registry/kube-controller-manager:v1.32.9"
  docker push "$registry/kube-controller-manager:v1.32.9"
  docker tag \
    "registry.k8s.io/kube-proxy:v1.32.9" \
    "$registry/kube-proxy:v1.32.9"
  docker push "$registry/kube-proxy:v1.32.9"
  docker tag \
    "registry.k8s.io/kube-scheduler:v1.32.9" \
    "$registry/kube-scheduler:v1.32.9"
  docker push "$registry/kube-scheduler:v1.32.9"
  docker tag \
    "registry.k8s.io/pause:3.10" \
    "$registry/pause:3.10"
  docker push "$registry/pause:3.10"
}

push_kubeadm_1_33_images() {
  echo
  echo "Pushing kubeadm Kubernetes 1.33.5 images to the $registry"

  docker tag \
    "registry.k8s.io/coredns/coredns:v1.12.0" \
    "$registry/coredns/coredns:v1.12.0"
  docker push "$registry/coredns/coredns:v1.12.0"
  docker tag \
    "registry.k8s.io/etcd:3.5.21-0" \
    "$registry/etcd:3.5.21-0"
  docker push "$registry/etcd:3.5.21-0"
  docker tag \
    "registry.k8s.io/kube-apiserver:v1.33.5" \
    "$registry/kube-apiserver:v1.33.5"
  docker push "$registry/kube-apiserver:v1.33.5"
  docker tag \
    "registry.k8s.io/kube-controller-manager:v1.33.5" \
    "$registry/kube-controller-manager:v1.33.5"
  docker push "$registry/kube-controller-manager:v1.33.5"
  docker tag \
    "registry.k8s.io/kube-proxy:v1.33.5" \
    "$registry/kube-proxy:v1.33.5"
  docker push "$registry/kube-proxy:v1.33.5"
  docker tag \
    "registry.k8s.io/kube-scheduler:v1.33.5" \
    "$registry/kube-scheduler:v1.33.5"
  docker push "$registry/kube-scheduler:v1.33.5"
  docker tag \
    "registry.k8s.io/pause:3.10" \
    "$registry/pause:3.10"
  docker push "$registry/pause:3.10"
}

push_kubeadm_1_34_images() {
  echo
  echo "Pushing kubeadm Kubernetes 1.34.1 images to the $registry"

  docker tag \
    "registry.k8s.io/coredns/coredns:v1.12.1" \
    "$registry/coredns/coredns:v1.12.1"
  docker push "$registry/coredns/coredns:v1.12.1"
  docker tag \
    "registry.k8s.io/etcd:3.6.4-0" \
    "$registry/etcd:3.6.4-0"
  docker push "$registry/etcd:3.6.4-0"
  docker tag \
    "registry.k8s.io/kube-apiserver:v1.34.1" \
    "$registry/kube-apiserver:v1.34.1"
  docker push "$registry/kube-apiserver:v1.34.1"
  docker tag \
    "registry.k8s.io/kube-controller-manager:v1.34.1" \
    "$registry/kube-controller-manager:v1.34.1"
  docker push "$registry/kube-controller-manager:v1.34.1"
  docker tag \
    "registry.k8s.io/kube-proxy:v1.34.1" \
    "$registry/kube-proxy:v1.34.1"
  docker push "$registry/kube-proxy:v1.34.1"
  docker tag \
    "registry.k8s.io/kube-scheduler:v1.34.1" \
    "$registry/kube-scheduler:v1.34.1"
  docker push "$registry/kube-scheduler:v1.34.1"
  docker tag \
    "registry.k8s.io/pause:3.10.1" \
    "$registry/pause:3.10.1"
  docker push "$registry/pause:3.10.1"
}


push_cm_kubernetes_setup_images() {
  echo
  echo "Pushing cm-kubernetes-setup images to the $registry"

  echo
  echo "Pushing containers for: alloy:1.2.1"
  docker tag \
    "docker.io/grafana/alloy:v1.10.1" \
    "$registry/grafana/alloy:v1.10.1"
  docker push "$registry/grafana/alloy:v1.10.1"
  docker tag \
    "quay.io/prometheus-operator/prometheus-config-reloader:v0.81.0" \
    "$registry/prometheus-operator/prometheus-config-reloader:v0.81.0"
  docker push "$registry/prometheus-operator/prometheus-config-reloader:v0.81.0"

  echo
  echo "Pushing containers for: calico"
  docker tag \
    "docker.io/calico/cni:v3.29.5" \
    "$registry/calico/cni:v3.29.5"
  docker push "$registry/calico/cni:v3.29.5"
  docker tag \
    "docker.io/calico/kube-controllers:v3.29.5" \
    "$registry/calico/kube-controllers:v3.29.5"
  docker push "$registry/calico/kube-controllers:v3.29.5"
  docker tag \
    "docker.io/calico/node:v3.29.5" \
    "$registry/calico/node:v3.29.5"
  docker push "$registry/calico/node:v3.29.5"
  docker tag \
    "docker.io/calico/typha:v3.29.5" \
    "$registry/calico/typha:v3.29.5"
  docker push "$registry/calico/typha:v3.29.5"

  echo
  echo "Pushing containers for: ceph-csi-rbd:3.15.0"
  docker tag \
    "quay.io/cephcsi/cephcsi:v3.15.0" \
    "$registry/cephcsi/cephcsi:v3.15.0"
  docker push "$registry/cephcsi/cephcsi:v3.15.0"
  docker tag \
    "registry.k8s.io/sig-storage/csi-attacher:v4.8.0" \
    "$registry/sig-storage/csi-attacher:v4.8.0"
  docker push "$registry/sig-storage/csi-attacher:v4.8.0"
  docker tag \
    "registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.13.0" \
    "$registry/sig-storage/csi-node-driver-registrar:v2.13.0"
  docker push "$registry/sig-storage/csi-node-driver-registrar:v2.13.0"
  docker tag \
    "registry.k8s.io/sig-storage/csi-provisioner:v5.1.0" \
    "$registry/sig-storage/csi-provisioner:v5.1.0"
  docker push "$registry/sig-storage/csi-provisioner:v5.1.0"
  docker tag \
    "registry.k8s.io/sig-storage/csi-resizer:v1.13.1" \
    "$registry/sig-storage/csi-resizer:v1.13.1"
  docker push "$registry/sig-storage/csi-resizer:v1.13.1"
  docker tag \
    "registry.k8s.io/sig-storage/csi-snapshotter:v8.2.0" \
    "$registry/sig-storage/csi-snapshotter:v8.2.0"
  docker push "$registry/sig-storage/csi-snapshotter:v8.2.0"

  echo
  echo "Pushing containers for: flannel"
  docker tag \
    "ghcr.io/flannel-io/flannel:v0.26.7" \
    "$registry/flannel-io/flannel:v0.26.7"
  docker push "$registry/flannel-io/flannel:v0.26.7"
  docker tag \
    "ghcr.io/flannel-io/flannel-cni-plugin:v1.6.2-flannel1" \
    "$registry/flannel-io/flannel-cni-plugin:v1.6.2-flannel1"
  docker push "$registry/flannel-io/flannel-cni-plugin:v1.6.2-flannel1"

  echo
  echo "Pushing containers for: gpu-operator:v25.3.3"
  docker tag \
    "nvcr.io/nvidia/cloud-native/gpu-operator-validator:v25.3.3" \
    "$registry/nvidia/cloud-native/gpu-operator-validator:v25.3.3"
  docker push "$registry/nvidia/cloud-native/gpu-operator-validator:v25.3.3"
  docker tag \
    "nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.8.1" \
    "$registry/nvidia/cloud-native/k8s-driver-manager:v0.8.1"
  docker push "$registry/nvidia/cloud-native/k8s-driver-manager:v0.8.1"
  docker tag \
    "nvcr.io/nvidia/cloud-native/k8s-mig-manager:v0.12.3-ubuntu20.04" \
    "$registry/nvidia/cloud-native/k8s-mig-manager:v0.12.3-ubuntu20.04"
  docker push "$registry/nvidia/cloud-native/k8s-mig-manager:v0.12.3-ubuntu20.04"
  docker tag \
    "nvcr.io/nvidia/cloud-native/vgpu-device-manager:v0.4.0" \
    "$registry/nvidia/cloud-native/vgpu-device-manager:v0.4.0"
  docker push "$registry/nvidia/cloud-native/vgpu-device-manager:v0.4.0"
  docker tag \
    "nvcr.io/nvidia/cuda:13.0.0-base-ubi9" \
    "$registry/nvidia/cuda:13.0.0-base-ubi9"
  docker push "$registry/nvidia/cuda:13.0.0-base-ubi9"
  docker tag \
    "nvcr.io/nvidia/gpu-operator:v25.3.3" \
    "$registry/nvidia/gpu-operator:v25.3.3"
  docker push "$registry/nvidia/gpu-operator:v25.3.3"
  docker tag \
    "nvcr.io/nvidia/k8s-device-plugin:v0.17.4" \
    "$registry/nvidia/k8s-device-plugin:v0.17.4"
  docker push "$registry/nvidia/k8s-device-plugin:v0.17.4"
  docker tag \
    "nvcr.io/nvidia/k8s/container-toolkit:v1.17.8-ubuntu20.04" \
    "$registry/nvidia/k8s/container-toolkit:v1.17.8-ubuntu20.04"
  docker push "$registry/nvidia/k8s/container-toolkit:v1.17.8-ubuntu20.04"
  docker tag \
    "nvcr.io/nvidia/k8s/dcgm-exporter:4.3.1-4.4.0-ubuntu22.04" \
    "$registry/nvidia/k8s/dcgm-exporter:4.3.1-4.4.0-ubuntu22.04"
  docker push "$registry/nvidia/k8s/dcgm-exporter:4.3.1-4.4.0-ubuntu22.04"
  docker tag \
    "nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.4.0" \
    "$registry/nvidia/kubevirt-gpu-device-plugin:v1.4.0"
  docker push "$registry/nvidia/kubevirt-gpu-device-plugin:v1.4.0"
  docker tag \
    "registry.k8s.io/nfd/node-feature-discovery:v0.17.3" \
    "$registry/nfd/node-feature-discovery:v0.17.3"
  docker push "$registry/nfd/node-feature-discovery:v0.17.3"

  echo
  echo "Pushing containers for: ingress_controller"
  # Digest stripped for image due to the docker behaviour:
  docker tag \
    "registry.k8s.io/ingress-nginx/controller:v1.12.5" \
    "$registry/ingress-nginx/controller:v1.12.5"
  docker push "$registry/ingress-nginx/controller:v1.12.5"
  # Digest stripped for image due to the docker behaviour:
  docker tag \
    "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.1" \
    "$registry/ingress-nginx/kube-webhook-certgen:v1.6.1"
  docker push "$registry/ingress-nginx/kube-webhook-certgen:v1.6.1"

  echo
  echo "Pushing containers for: k8s-nim-operator:2.0.2"
  docker tag \
    "nvcr.io/nvidia/cloud-native/k8s-nim-operator:v2.0.2" \
    "$registry/nvidia/cloud-native/k8s-nim-operator:v2.0.2"
  docker push "$registry/nvidia/cloud-native/k8s-nim-operator:v2.0.2"

  echo
  echo "Pushing containers for: kube-prometheus-stack:77.6.2"
  docker tag \
    "docker.io/bats/bats:v1.4.1" \
    "$registry/bats/bats:v1.4.1"
  docker push "$registry/bats/bats:v1.4.1"
  docker tag \
    "docker.io/grafana/grafana:12.1.1" \
    "$registry/grafana/grafana:12.1.1"
  docker push "$registry/grafana/grafana:12.1.1"
  docker tag \
    "quay.io/kiwigrid/k8s-sidecar:1.30.10" \
    "$registry/kiwigrid/k8s-sidecar:1.30.10"
  docker push "$registry/kiwigrid/k8s-sidecar:1.30.10"
  docker tag \
    "quay.io/prometheus-operator/prometheus-config-reloader:v0.85.0" \
    "$registry/prometheus-operator/prometheus-config-reloader:v0.85.0"
  docker push "$registry/prometheus-operator/prometheus-config-reloader:v0.85.0"
  docker tag \
    "quay.io/prometheus-operator/prometheus-operator:v0.85.0" \
    "$registry/prometheus-operator/prometheus-operator:v0.85.0"
  docker push "$registry/prometheus-operator/prometheus-operator:v0.85.0"
  docker tag \
    "quay.io/prometheus/alertmanager:v0.28.1" \
    "$registry/prometheus/alertmanager:v0.28.1"
  docker push "$registry/prometheus/alertmanager:v0.28.1"
  docker tag \
    "quay.io/prometheus/node-exporter:v1.9.1" \
    "$registry/prometheus/node-exporter:v1.9.1"
  docker push "$registry/prometheus/node-exporter:v1.9.1"
  docker tag \
    "quay.io/prometheus/prometheus:v3.5.0" \
    "$registry/prometheus/prometheus:v3.5.0"
  docker push "$registry/prometheus/prometheus:v3.5.0"
  docker tag \
    "quay.io/thanos/thanos:v0.39.2" \
    "$registry/thanos/thanos:v0.39.2"
  docker push "$registry/thanos/thanos:v0.39.2"
  docker tag \
    "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.2" \
    "$registry/ingress-nginx/kube-webhook-certgen:v1.6.2"
  docker push "$registry/ingress-nginx/kube-webhook-certgen:v1.6.2"

  echo
  echo "Pushing containers for: kube-prometheus-stack:77.6.2,kube-state-metrics:6.3.0"
  docker tag \
    "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0" \
    "$registry/kube-state-metrics/kube-state-metrics:v2.17.0"
  docker push "$registry/kube-state-metrics/kube-state-metrics:v2.17.0"

  echo
  echo "Pushing containers for: kubernetes-dashboard:7.13.0"
  docker tag \
    "docker.io/kong:3.8" \
    "$registry/kong:3.8"
  docker push "$registry/kong:3.8"
  docker tag \
    "docker.io/kubernetesui/dashboard-api:1.13.0" \
    "$registry/kubernetesui/dashboard-api:1.13.0"
  docker push "$registry/kubernetesui/dashboard-api:1.13.0"
  docker tag \
    "docker.io/kubernetesui/dashboard-auth:1.3.0" \
    "$registry/kubernetesui/dashboard-auth:1.3.0"
  docker push "$registry/kubernetesui/dashboard-auth:1.3.0"
  docker tag \
    "docker.io/kubernetesui/dashboard-metrics-scraper:1.2.2" \
    "$registry/kubernetesui/dashboard-metrics-scraper:1.2.2"
  docker push "$registry/kubernetesui/dashboard-metrics-scraper:1.2.2"
  docker tag \
    "docker.io/kubernetesui/dashboard-web:1.7.0" \
    "$registry/kubernetesui/dashboard-web:1.7.0"
  docker push "$registry/kubernetesui/dashboard-web:1.7.0"

  # Manually Added by CC
  echo
  echo "Pushing containers for: busybox (utility images)"

  docker tag docker.io/library/busybox:1.31.1 \
    "$registry/library/busybox:1.31.1"
  docker push "$registry/library/busybox:1.31.1"

  docker tag docker.io/library/busybox:1.35 \
    "$registry/library/busybox:1.35"
  docker push "$registry/library/busybox:1.35"

  docker tag docker.io/library/busybox:1.37.0 \
    "$registry/library/busybox:1.37.0"
  docker push "$registry/library/busybox:1.37.0"

  echo
  echo "Pushing containers for: kyverno:3.5.1"
# Added to the busybox section
#  docker tag \
#    "docker.io/busybox:1.35" \
#    "$registry/busybox:1.35"
#  docker push "$registry/busybox:1.35"
  docker tag \
    "reg.kyverno.io/kyverno/background-controller:v1.15.1" \
    "$registry/kyverno/background-controller:v1.15.1"
  docker push "$registry/kyverno/background-controller:v1.15.1"
  docker tag \
    "reg.kyverno.io/kyverno/cleanup-controller:v1.15.1" \
    "$registry/kyverno/cleanup-controller:v1.15.1"
  docker push "$registry/kyverno/cleanup-controller:v1.15.1"
  docker tag \
    "reg.kyverno.io/kyverno/kyverno:v1.15.1" \
    "$registry/kyverno/kyverno:v1.15.1"
  docker push "$registry/kyverno/kyverno:v1.15.1"
  docker tag \
    "reg.kyverno.io/kyverno/kyverno-cli:v1.15.1" \
    "$registry/kyverno/kyverno-cli:v1.15.1"
  docker push "$registry/kyverno/kyverno-cli:v1.15.1"
  docker tag \
    "reg.kyverno.io/kyverno/kyvernopre:v1.15.1" \
    "$registry/kyverno/kyvernopre:v1.15.1"
  docker push "$registry/kyverno/kyvernopre:v1.15.1"
  docker tag \
    "reg.kyverno.io/kyverno/reports-controller:v1.15.1" \
    "$registry/kyverno/reports-controller:v1.15.1"
  docker push "$registry/kyverno/reports-controller:v1.15.1"
  docker tag \
    "registry.k8s.io/kubectl:v1.32.7" \
    "$registry/kubectl:v1.32.7"
  docker push "$registry/kubectl:v1.32.7"

  echo
  echo "Pushing containers for: loki:6.40.0"
  docker tag \
    "docker.io/grafana/loki:3.5.3" \
    "$registry/grafana/loki:3.5.3"
  docker push "$registry/grafana/loki:3.5.3"
  docker tag \
    "docker.io/grafana/loki-canary:3.5.3" \
    "$registry/grafana/loki-canary:3.5.3"
  docker push "$registry/grafana/loki-canary:3.5.3"
  docker tag \
    "docker.io/grafana/loki-helm-test:ewelch-distributed-helm-chart-17db5ee" \
    "$registry/grafana/loki-helm-test:ewelch-distributed-helm-chart-17db5ee"
  docker push "$registry/grafana/loki-helm-test:ewelch-distributed-helm-chart-17db5ee"
  docker tag \
    "docker.io/kiwigrid/k8s-sidecar:1.30.7" \
    "$registry/kiwigrid/k8s-sidecar:1.30.7"
  docker push "$registry/kiwigrid/k8s-sidecar:1.30.7"
  docker tag \
    "docker.io/memcached:1.6.38-alpine" \
    "$registry/memcached:1.6.38-alpine"
  docker push "$registry/memcached:1.6.38-alpine"
  docker tag \
    "docker.io/nginxinc/nginx-unprivileged:1.29-alpine" \
    "$registry/nginxinc/nginx-unprivileged:1.29-alpine"
  docker push "$registry/nginxinc/nginx-unprivileged:1.29-alpine"
  docker tag \
    "docker.io/prom/memcached-exporter:v0.15.3" \
    "$registry/prom/memcached-exporter:v0.15.3"
  docker push "$registry/prom/memcached-exporter:v0.15.3"
  docker tag \
    "quay.io/minio/mc:RELEASE.2024-11-21T17-21-54Z" \
    "$registry/minio/mc:RELEASE.2024-11-21T17-21-54Z"
  docker push "$registry/minio/mc:RELEASE.2024-11-21T17-21-54Z"
  docker tag \
    "quay.io/minio/minio:RELEASE.2024-12-18T13-15-44Z" \
    "$registry/minio/minio:RELEASE.2024-12-18T13-15-44Z"
  docker push "$registry/minio/minio:RELEASE.2024-12-18T13-15-44Z"

  echo
  echo "Pushing containers for: lws:v0.7.0"
  docker tag \
    "registry.k8s.io/lws/lws:v0.7.0" \
    "$registry/lws/lws:v0.7.0"
  docker push "$registry/lws/lws:v0.7.0"

  echo
  echo "Pushing containers for: metallb:0.15.2"
  docker tag \
    "quay.io/frrouting/frr:9.1.0" \
    "$registry/frrouting/frr:9.1.0"
  docker push "$registry/frrouting/frr:9.1.0"
  docker tag \
    "quay.io/metallb/controller:v0.15.2" \
    "$registry/metallb/controller:v0.15.2"
  docker push "$registry/metallb/controller:v0.15.2"
  docker tag \
    "quay.io/metallb/speaker:v0.15.2" \
    "$registry/metallb/speaker:v0.15.2"
  docker push "$registry/metallb/speaker:v0.15.2"

  echo
  echo "Pushing containers for: metrics-server:3.13.0"
  docker tag \
    "registry.k8s.io/metrics-server/metrics-server:v0.8.0" \
    "$registry/metrics-server/metrics-server:v0.8.0"
  docker push "$registry/metrics-server/metrics-server:v0.8.0"

  echo
  echo "Pushing containers for: network-operator:25.7.0"
  docker tag \
    "gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0" \
    "$registry/kubebuilder/kube-rbac-proxy:v0.15.0"
  docker push "$registry/kubebuilder/kube-rbac-proxy:v0.15.0"
  docker tag \
    "ghcr.io/k8snetworkplumbingwg/network-resources-injector:v1.7.0" \
    "$registry/k8snetworkplumbingwg/network-resources-injector:v1.7.0"
  docker push "$registry/k8snetworkplumbingwg/network-resources-injector:v1.7.0"
  docker tag \
    "nvcr.io/nvidia/cloud-native/network-operator:v25.7.0" \
    "$registry/nvidia/cloud-native/network-operator:v25.7.0"
  docker push "$registry/nvidia/cloud-native/network-operator:v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/ib-sriov-cni:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/ib-sriov-cni:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/ib-sriov-cni:network-operator-v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/network-operator-init-container:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/network-operator-init-container:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/network-operator-init-container:network-operator-v25.7.0"
  docker tag \
  "nvcr.io/nvidia/mellanox/node-feature-discovery:network-operator-v25.7.0" \
  "$registry/nvidia/mellanox/node-feature-discovery:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/node-feature-discovery:network-operator-v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/ovs-cni-plugin:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/ovs-cni-plugin:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/ovs-cni-plugin:network-operator-v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/sriov-cni:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/sriov-cni:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/sriov-cni:network-operator-v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/sriov-network-device-plugin:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/sriov-network-device-plugin:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/sriov-network-device-plugin:network-operator-v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/sriov-network-operator:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/sriov-network-operator:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/sriov-network-operator:network-operator-v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/sriov-network-operator-config-daemon:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/sriov-network-operator-config-daemon:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/sriov-network-operator-config-daemon:network-operator-v25.7.0"
  docker tag \
    "nvcr.io/nvidia/mellanox/sriov-network-operator-webhook:network-operator-v25.7.0" \
    "$registry/nvidia/mellanox/sriov-network-operator-webhook:network-operator-v25.7.0"
  docker push "$registry/nvidia/mellanox/sriov-network-operator-webhook:network-operator-v25.7.0"
  # manually added
  docker tag \
    "ghcr.io/k8snetworkplumbingwg/plugins:v1.6.2-update.1" \
    "$registry/k8snetworkplumbingwg/plugins:v1.6.2-update.1"
  docker push "$registry/k8snetworkplumbingwg/plugins:v1.6.2-update.1"
  docker tag \
    "ghcr.io/k8snetworkplumbingwg/multus-cni:v4.1.0" \
    "$registry/k8snetworkplumbingwg/multus-cni:v4.1.0"
  docker push "$registry/k8snetworkplumbingwg/multus-cni:v4.1.0"
  docker tag \
    "ghcr.io/mellanox/nvidia-k8s-ipam:v0.2.0" \
    "$registry/mellanox/nvidia-k8s-ipam:v0.2.0"
  docker push "$registry/mellanox/nvidia-k8s-ipam:v0.2.0"

  # Manually Added by CC – Network Operator SR-IOV legacy image
  docker tag \
    "nvcr.io/nvidia/mellanox/sriov-network-operator:network-operator-25.4.0" \
    "$registry/nvidia/mellanox/sriov-network-operator:network-operator-25.4.0"

  docker push \
    "$registry/nvidia/mellanox/sriov-network-operator:network-operator-25.4.0"

  # Network Operator – NFD image expected by chart (airgap fix)
  docker tag \
    "nvcr.io/nvidia/mellanox/node-feature-discovery:network-operator-v25.7.0" \
    "$registry/nfd/node-feature-discovery:network-operator-v25.7.0"

  docker push \
    "$registry/nfd/node-feature-discovery:network-operator-v25.7.0"

  echo
  echo "Pushing containers for: postgres-operator:1.14.0"
  docker tag \
    "ghcr.io/zalando/postgres-operator:v1.14.0" \
    "$registry/zalando/postgres-operator:v1.14.0"
  docker push "$registry/zalando/postgres-operator:v1.14.0"

  # postgres-operator dependencies
  docker tag \
    "ghcr.io/zalando/postgres-operator/logical-backup:v1.13.0" \
    "$registry/zalando/postgres-operator/logical-backup:v1.13.0"
  docker push "$registry/zalando/postgres-operator/logical-backup:v1.13.0"

  docker tag \
    "ghcr.io/zalando/spilo-17:4.0-p2" \
    "$registry/zalando/spilo-17:4.0-p2"
  docker push "$registry/zalando/spilo-17:4.0-p2"

  docker tag \
    "registry.opensource.zalan.do/acid/pgbouncer:master-32" \
    "$registry/acid/pgbouncer:master-32"
  docker push "$registry/acid/pgbouncer:master-32"

  echo
  echo "Pushing containers for: prometheus-adapter:5.1.0"
  docker tag \
    "registry.k8s.io/prometheus-adapter/prometheus-adapter:v0.12.0" \
    "$registry/prometheus-adapter/prometheus-adapter:v0.12.0"
  docker push "$registry/prometheus-adapter/prometheus-adapter:v0.12.0"

  echo
  echo "Pushing containers for: promtail:6.17.0"
  docker tag \
    "docker.io/grafana/promtail:3.5.1" \
    "$registry/grafana/promtail:3.5.1"
  docker push "$registry/grafana/promtail:3.5.1"

  echo
  echo "Pushing containers for: spark-operator:2.3.0"
  docker tag \
    "ghcr.io/kubeflow/spark-operator/controller:2.3.0" \
    "$registry/kubeflow/spark-operator/controller:2.3.0"
  docker push "$registry/kubeflow/spark-operator/controller:2.3.0"
}

push_local_path_provisioner_images() {
  echo
  echo "Pushing local-path-provisioner:0.0.31 images to the $registry"

  docker tag "docker.io/rancher/local-path-provisioner:v0.0.31" "$registry/rancher/local-path-provisioner:v0.0.31"
  docker push "$registry/rancher/local-path-provisioner:v0.0.31"
}

push_cm_kubernetes_permissions_manager_images() {
  echo
  echo "Pushing cm-kubernetes-permissions-manager:0.6.6 images to the $registry"

  docker tag "docker.io/brightcomputing/cm-kubernetes-permissions-manager-controller:0.6.6" "$registry/brightcomputing/cm-kubernetes-permissions-manager-controller:0.6.6"
  docker push "$registry/brightcomputing/cm-kubernetes-permissions-manager-controller:0.6.6"
}

push_cm_jupyter_kernel_operator_images() {
  echo
  echo "Pushing cm-jupyter-kernel-operator:0.3.7 images to the $registry"

  docker tag "docker.io/brightcomputing/cm-jupyter-kernel-operator-controller:0.3.7" "$registry/brightcomputing/cm-jupyter-kernel-operator-controller:0.3.7"
  docker push "$registry/brightcomputing/cm-jupyter-kernel-operator-controller:0.3.7"

  docker tag "docker.io/brightcomputing/cm-jupyter-kernel-operator-sidecar:0.3.7" "$registry/brightcomputing/cm-jupyter-kernel-operator-sidecar:0.3.7"
  docker push "$registry/brightcomputing/cm-jupyter-kernel-operator-sidecar:0.3.7"
}

push_mpi_operator_images() {
  echo
  echo "Pushing mpi-operator:0.6.0 images to the $registry"

  docker tag "docker.io/mpioperator/mpi-operator:0.6.0" "$registry/mpioperator/mpi-operator:0.6.0"
  docker push "$registry/mpioperator/mpi-operator:0.6.0"
}

pushd k8s-images || exit 1
prepare_docker

load_images
push_kubeadm_images
push_cm_kubernetes_setup_images
push_local_path_provisioner_images
push_cm_kubernetes_permissions_manager_images
push_cm_jupyter_kernel_operator_images
push_mpi_operator_images

popd || exit 1
