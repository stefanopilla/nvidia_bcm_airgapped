#!/usr/bin/env bash
# This is a CC modified version
set -eu -o pipefail

KUBE_VERSION="1.31"
module_loaded=false

for i in "$@"; do
  case $i in
    --kube-version=*)
      KUBE_VERSION="${i#*=}"
      ;;
    -h|--help)
      echo "Use $0 to pull images for air-gapped cm-kubernetes-setup."
      echo "Kube version can be selected by option '--kube-version=<version>'. Default is '$KUBE_VERSION'."
      echo "Kube version selection is done without patch and should be consistent with packages to install."
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
}

logout_docker() {
  if [ $module_loaded = true ]; then
    module unload docker
  fi
}
trap logout_docker EXIT

pull_kubeadm_images() {
  case $KUBE_VERSION in
  "1.32")
    pull_kubeadm_1_32_images
    ;;
  "1.33")
    pull_kubeadm_1_33_images
    ;;
  "1.34")
    pull_kubeadm_1_34_images
    ;;
  *)
    echo "Not supported kube version: '$KUBE_VERSION'"
    exit 1
    ;;
  esac
}

save_kubeadm_images() {
  case $KUBE_VERSION in
  "1.32")
    save_kubeadm_1_32_images
    ;;
  "1.33")
    save_kubeadm_1_33_images
    ;;
  "1.34")
    save_kubeadm_1_34_images
    ;;
  *)
    echo "Not supported kube version: '$KUBE_VERSION'"
    exit 1
    ;;
  esac
}

pull_kubeadm_1_32_images() {
  echo
  echo "Pulling kubeadm Kubernetes 1.32.9 images..."

  docker pull "registry.k8s.io/coredns/coredns:v1.11.3"
  docker pull "registry.k8s.io/etcd:3.5.16-0"
  docker pull "registry.k8s.io/kube-apiserver:v1.32.9"
  docker pull "registry.k8s.io/kube-controller-manager:v1.32.9"
  docker pull "registry.k8s.io/kube-proxy:v1.32.9"
  docker pull "registry.k8s.io/kube-scheduler:v1.32.9"
  docker pull "registry.k8s.io/pause:3.10"
}

save_kubeadm_1_32_images() {
  echo
  echo "Saving kubeadm Kubernetes 1.32.9 images to the archive"

  docker save \
    "registry.k8s.io/coredns/coredns:v1.11.3" \
    "registry.k8s.io/etcd:3.5.16-0" \
    "registry.k8s.io/kube-apiserver:v1.32.9" \
    "registry.k8s.io/kube-controller-manager:v1.32.9" \
    "registry.k8s.io/kube-proxy:v1.32.9" \
    "registry.k8s.io/kube-scheduler:v1.32.9" \
    "registry.k8s.io/pause:3.10" \
  -o "kubeadm_1_32_images_kube_1.32.9.tar"
}

pull_kubeadm_1_33_images() {
  echo
  echo "Pulling kubeadm Kubernetes 1.33.5 images..."

  docker pull "registry.k8s.io/coredns/coredns:v1.12.0"
  docker pull "registry.k8s.io/etcd:3.5.21-0"
  docker pull "registry.k8s.io/kube-apiserver:v1.33.5"
  docker pull "registry.k8s.io/kube-controller-manager:v1.33.5"
  docker pull "registry.k8s.io/kube-proxy:v1.33.5"
  docker pull "registry.k8s.io/kube-scheduler:v1.33.5"
  docker pull "registry.k8s.io/pause:3.10"
}

save_kubeadm_1_33_images() {
  echo
  echo "Saving kubeadm Kubernetes 1.33.5 images to the archive"

  docker save \
    "registry.k8s.io/coredns/coredns:v1.12.0" \
    "registry.k8s.io/etcd:3.5.21-0" \
    "registry.k8s.io/kube-apiserver:v1.33.5" \
    "registry.k8s.io/kube-controller-manager:v1.33.5" \
    "registry.k8s.io/kube-proxy:v1.33.5" \
    "registry.k8s.io/kube-scheduler:v1.33.5" \
    "registry.k8s.io/pause:3.10" \
  -o "kubeadm_1_33_images_kube_1.33.5.tar"
}

pull_kubeadm_1_34_images() {
  echo
  echo "Pulling kubeadm Kubernetes 1.34.1 images..."

  docker pull "registry.k8s.io/coredns/coredns:v1.12.1"
  docker pull "registry.k8s.io/etcd:3.6.4-0"
  docker pull "registry.k8s.io/kube-apiserver:v1.34.1"
  docker pull "registry.k8s.io/kube-controller-manager:v1.34.1"
  docker pull "registry.k8s.io/kube-proxy:v1.34.1"
  docker pull "registry.k8s.io/kube-scheduler:v1.34.1"
  docker pull "registry.k8s.io/pause:3.10.1"
}

save_kubeadm_1_34_images() {
  echo
  echo "Saving kubeadm Kubernetes 1.34.1 images to the archive"

  docker save \
    "registry.k8s.io/coredns/coredns:v1.12.1" \
    "registry.k8s.io/etcd:3.6.4-0" \
    "registry.k8s.io/kube-apiserver:v1.34.1" \
    "registry.k8s.io/kube-controller-manager:v1.34.1" \
    "registry.k8s.io/kube-proxy:v1.34.1" \
    "registry.k8s.io/kube-scheduler:v1.34.1" \
    "registry.k8s.io/pause:3.10.1" \
  -o "kubeadm_1_34_images_kube_1.34.1.tar"
}


pull_cm_kubernetes_setup_images() {
  echo
  echo "Pulling cm-kubernetes-setup images..."

  echo
  echo "Pulling containers for: alloy:1.2.1"
  docker pull "docker.io/grafana/alloy:v1.10.1"
  docker pull "quay.io/prometheus-operator/prometheus-config-reloader:v0.81.0"

  echo
  echo "Pulling containers for: calico"
  docker pull "docker.io/calico/cni:v3.29.5"
  docker pull "docker.io/calico/kube-controllers:v3.29.5"
  docker pull "docker.io/calico/node:v3.29.5"
  docker pull "docker.io/calico/typha:v3.29.5"

  echo
  echo "Pulling containers for: ceph-csi-rbd:3.15.0"
  docker pull "quay.io/cephcsi/cephcsi:v3.15.0"
  docker pull "registry.k8s.io/sig-storage/csi-attacher:v4.8.0"
  docker pull "registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.13.0"
  docker pull "registry.k8s.io/sig-storage/csi-provisioner:v5.1.0"
  docker pull "registry.k8s.io/sig-storage/csi-resizer:v1.13.1"
  docker pull "registry.k8s.io/sig-storage/csi-snapshotter:v8.2.0"

  echo
  echo "Pulling containers for: flannel"
  docker pull "ghcr.io/flannel-io/flannel:v0.26.7"
  docker pull "ghcr.io/flannel-io/flannel-cni-plugin:v1.6.2-flannel1"

  echo
  echo "Pulling containers for: gpu-operator:v25.3.3"
  docker pull "nvcr.io/nvidia/cloud-native/gpu-operator-validator:v25.3.3"
  docker pull "nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.8.1"
  docker pull "nvcr.io/nvidia/cloud-native/k8s-mig-manager:v0.12.3-ubuntu20.04"
  docker pull "nvcr.io/nvidia/cloud-native/vgpu-device-manager:v0.4.0"
  docker pull "nvcr.io/nvidia/cuda:13.0.0-base-ubi9"
  docker pull "nvcr.io/nvidia/gpu-operator:v25.3.3"
  docker pull "nvcr.io/nvidia/k8s-device-plugin:v0.17.4"
  docker pull "nvcr.io/nvidia/k8s/container-toolkit:v1.17.8-ubuntu20.04"
  docker pull "nvcr.io/nvidia/k8s/dcgm-exporter:4.3.1-4.4.0-ubuntu22.04"
  docker pull "nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.4.0"
  # NOTE:
  # - registry.k8s.io/nfd/... is used by GPU Operator
  # - nvcr.io/nvidia/mellanox/node-feature-discovery is used by Network Operator
  docker pull "registry.k8s.io/nfd/node-feature-discovery:v0.17.3"

  echo
  echo "Pulling containers for: ingress_controller"
  docker pull "registry.k8s.io/ingress-nginx/controller:v1.12.5"
  docker pull "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.1"

  echo
  echo "Pulling containers for: k8s-nim-operator:2.0.2"
  docker pull "nvcr.io/nvidia/cloud-native/k8s-nim-operator:v2.0.2"

  echo
  echo "Pulling containers for: kube-prometheus-stack:77.6.2"
  docker pull "docker.io/bats/bats:v1.4.1"
  docker pull "docker.io/grafana/grafana:12.1.1"
  docker pull "quay.io/kiwigrid/k8s-sidecar:1.30.10"
  docker pull "quay.io/prometheus-operator/prometheus-config-reloader:v0.85.0"
  docker pull "quay.io/prometheus-operator/prometheus-operator:v0.85.0"
  docker pull "quay.io/prometheus/alertmanager:v0.28.1"
  docker pull "quay.io/prometheus/node-exporter:v1.9.1"
  docker pull "quay.io/prometheus/prometheus:v3.5.0"
  docker pull "quay.io/thanos/thanos:v0.39.2"
  docker pull "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.2"
  # Added busybox (utility images) section
  # docker pull "docker.io/busybox:1.37.0"
  
  echo
  echo "Pulling containers for: busybox (utility images)"
  docker pull docker.io/library/busybox:1.31.1
  docker pull docker.io/library/busybox:1.35
  docker pull docker.io/library/busybox:1.37.0

  echo
  echo "Pulling containers for: kube-prometheus-stack:77.6.2,kube-state-metrics:6.3.0"
  docker pull "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0"

  echo
  echo "Pulling containers for: kubernetes-dashboard:7.13.0"
  docker pull "docker.io/kong:3.8"
  docker pull "docker.io/kubernetesui/dashboard-api:1.13.0"
  docker pull "docker.io/kubernetesui/dashboard-auth:1.3.0"
  docker pull "docker.io/kubernetesui/dashboard-metrics-scraper:1.2.2"
  docker pull "docker.io/kubernetesui/dashboard-web:1.7.0"

  echo
  echo "Pulling containers for: kyverno:3.5.1"
  # Added busybox (utility images) section
  # docker pull "docker.io/busybox:1.35"
  docker pull "reg.kyverno.io/kyverno/background-controller:v1.15.1"
  docker pull "reg.kyverno.io/kyverno/cleanup-controller:v1.15.1"
  docker pull "reg.kyverno.io/kyverno/kyverno:v1.15.1"
  docker pull "reg.kyverno.io/kyverno/kyverno-cli:v1.15.1"
  docker pull "reg.kyverno.io/kyverno/kyvernopre:v1.15.1"
  docker pull "reg.kyverno.io/kyverno/reports-controller:v1.15.1"
  docker pull "registry.k8s.io/kubectl:v1.32.7"

  echo
  echo "Pulling containers for: loki:6.40.0"
  docker pull "docker.io/grafana/loki:3.5.3"
  docker pull "docker.io/grafana/loki-canary:3.5.3"
  docker pull "docker.io/grafana/loki-helm-test:ewelch-distributed-helm-chart-17db5ee"
  docker pull "docker.io/kiwigrid/k8s-sidecar:1.30.7"
  docker pull "docker.io/memcached:1.6.38-alpine"
  docker pull "docker.io/nginxinc/nginx-unprivileged:1.29-alpine"
  docker pull "docker.io/prom/memcached-exporter:v0.15.3"
  docker pull "quay.io/minio/mc:RELEASE.2024-11-21T17-21-54Z"
  docker pull "quay.io/minio/minio:RELEASE.2024-12-18T13-15-44Z"

  echo
  echo "Pulling containers for: lws:v0.7.0"
  docker pull "registry.k8s.io/lws/lws:v0.7.0"

  echo
  echo "Pulling containers for: metallb:0.15.2"
  docker pull "quay.io/frrouting/frr:9.1.0"
  docker pull "quay.io/metallb/controller:v0.15.2"
  docker pull "quay.io/metallb/speaker:v0.15.2"

  echo
  echo "Pulling containers for: metrics-server:3.13.0"
  docker pull "registry.k8s.io/metrics-server/metrics-server:v0.8.0"

  echo
  echo "Pulling containers for: network-operator:25.7.0"
  docker pull "gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0"
  docker pull "ghcr.io/k8snetworkplumbingwg/network-resources-injector:v1.7.0"
  docker pull "nvcr.io/nvidia/cloud-native/network-operator:v25.7.0"
  # NOTE:
  # - registry.k8s.io/nfd/... is used by GPU Operator
  # - nvcr.io/nvidia/mellanox/node-feature-discovery is used by Network Operator
  docker pull "nvcr.io/nvidia/mellanox/ib-sriov-cni:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/network-operator-init-container:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/node-feature-discovery:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/ovs-cni-plugin:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/sriov-cni:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/sriov-network-device-plugin:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/sriov-network-operator:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/sriov-network-operator-config-daemon:network-operator-v25.7.0"
  docker pull "nvcr.io/nvidia/mellanox/sriov-network-operator-webhook:network-operator-v25.7.0"
  # manually added, temporary
  docker pull "ghcr.io/k8snetworkplumbingwg/plugins:v1.6.2-update.1"
  docker pull "ghcr.io/k8snetworkplumbingwg/multus-cni:v4.1.0"
  docker pull "ghcr.io/mellanox/nvidia-k8s-ipam:v0.2.0"
  docker pull "nvcr.io/nvidia/mellanox/sriov-network-operator:network-operator-25.4.0"

  echo
  echo "Pulling containers for: postgres-operator:1.14.0"
  docker pull "ghcr.io/zalando/postgres-operator:v1.14.0"

  # postgres-operator dependencies (used by helm chart)
  docker pull "ghcr.io/zalando/postgres-operator/logical-backup:v1.13.0"
  docker pull "ghcr.io/zalando/spilo-17:4.0-p2"
  docker pull "registry.opensource.zalan.do/acid/pgbouncer:master-32"

  echo
  echo "Pulling containers for: prometheus-adapter:5.1.0"
  docker pull "registry.k8s.io/prometheus-adapter/prometheus-adapter:v0.12.0"

  echo
  echo "Pulling containers for: promtail:6.17.0"
  docker pull "docker.io/grafana/promtail:3.5.1"

  echo
  echo "Pulling containers for: spark-operator:2.3.0"
  docker pull "ghcr.io/kubeflow/spark-operator/controller:2.3.0"
}

save_cm_kubernetes_setup_images() {
  echo
  echo "Saving cm-kubernetes-setup images to the archive"

  docker save \
    "docker.io/grafana/alloy:v1.10.1" \
    "quay.io/prometheus-operator/prometheus-config-reloader:v0.81.0" \
    "docker.io/calico/cni:v3.29.5" \
    "docker.io/calico/kube-controllers:v3.29.5" \
    "docker.io/calico/node:v3.29.5" \
    "docker.io/calico/typha:v3.29.5" \
    "quay.io/cephcsi/cephcsi:v3.15.0" \
    "registry.k8s.io/sig-storage/csi-attacher:v4.8.0" \
    "registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.13.0" \
    "registry.k8s.io/sig-storage/csi-provisioner:v5.1.0" \
    "registry.k8s.io/sig-storage/csi-resizer:v1.13.1" \
    "registry.k8s.io/sig-storage/csi-snapshotter:v8.2.0" \
    "ghcr.io/flannel-io/flannel:v0.26.7" \
    "ghcr.io/flannel-io/flannel-cni-plugin:v1.6.2-flannel1" \
    "nvcr.io/nvidia/cloud-native/gpu-operator-validator:v25.3.3" \
    "nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.8.1" \
    "nvcr.io/nvidia/cloud-native/k8s-mig-manager:v0.12.3-ubuntu20.04" \
    "nvcr.io/nvidia/cloud-native/vgpu-device-manager:v0.4.0" \
    "nvcr.io/nvidia/cuda:13.0.0-base-ubi9" \
    "nvcr.io/nvidia/gpu-operator:v25.3.3" \
    "nvcr.io/nvidia/k8s-device-plugin:v0.17.4" \
    "nvcr.io/nvidia/k8s/container-toolkit:v1.17.8-ubuntu20.04" \
    "nvcr.io/nvidia/k8s/dcgm-exporter:4.3.1-4.4.0-ubuntu22.04" \
    "nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.4.0" \
    "registry.k8s.io/nfd/node-feature-discovery:v0.17.3" \
    "registry.k8s.io/ingress-nginx/controller:v1.12.5" \
    "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.1" \
    "nvcr.io/nvidia/cloud-native/k8s-nim-operator:v2.0.2" \
    "docker.io/bats/bats:v1.4.1" \
    "docker.io/grafana/grafana:12.1.1" \
    "quay.io/kiwigrid/k8s-sidecar:1.30.10" \
    "quay.io/prometheus-operator/prometheus-config-reloader:v0.85.0" \
    "quay.io/prometheus-operator/prometheus-operator:v0.85.0" \
    "quay.io/prometheus/alertmanager:v0.28.1" \
    "quay.io/prometheus/node-exporter:v1.9.1" \
    "quay.io/prometheus/prometheus:v3.5.0" \
    "quay.io/thanos/thanos:v0.39.2" \
    "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.2" \
    "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0" \
    "docker.io/kong:3.8" \
    "docker.io/kubernetesui/dashboard-api:1.13.0" \
    "docker.io/kubernetesui/dashboard-auth:1.3.0" \
    "docker.io/kubernetesui/dashboard-metrics-scraper:1.2.2" \
    "docker.io/kubernetesui/dashboard-web:1.7.0" \
    "docker.io/busybox:1.31.1" \
    "docker.io/busybox:1.37.0" \
    "docker.io/busybox:1.35" \
    "reg.kyverno.io/kyverno/background-controller:v1.15.1" \
    "reg.kyverno.io/kyverno/cleanup-controller:v1.15.1" \
    "reg.kyverno.io/kyverno/kyverno:v1.15.1" \
    "reg.kyverno.io/kyverno/kyverno-cli:v1.15.1" \
    "reg.kyverno.io/kyverno/kyvernopre:v1.15.1" \
    "reg.kyverno.io/kyverno/reports-controller:v1.15.1" \
    "registry.k8s.io/kubectl:v1.32.7" \
    "docker.io/grafana/loki:3.5.3" \
    "docker.io/grafana/loki-canary:3.5.3" \
    "docker.io/grafana/loki-helm-test:ewelch-distributed-helm-chart-17db5ee" \
    "docker.io/kiwigrid/k8s-sidecar:1.30.7" \
    "docker.io/memcached:1.6.38-alpine" \
    "docker.io/nginxinc/nginx-unprivileged:1.29-alpine" \
    "docker.io/prom/memcached-exporter:v0.15.3" \
    "quay.io/minio/mc:RELEASE.2024-11-21T17-21-54Z" \
    "quay.io/minio/minio:RELEASE.2024-12-18T13-15-44Z" \
    "registry.k8s.io/lws/lws:v0.7.0" \
    "quay.io/frrouting/frr:9.1.0" \
    "quay.io/metallb/controller:v0.15.2" \
    "quay.io/metallb/speaker:v0.15.2" \
    "registry.k8s.io/metrics-server/metrics-server:v0.8.0" \
    "gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0" \
    "ghcr.io/k8snetworkplumbingwg/network-resources-injector:v1.7.0" \
    "nvcr.io/nvidia/cloud-native/network-operator:v25.7.0" \
    "nvcr.io/nvidia/mellanox/sriov-network-operator:network-operator-25.4.0" \
    "nvcr.io/nvidia/mellanox/ib-sriov-cni:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/network-operator-init-container:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/node-feature-discovery:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/ovs-cni-plugin:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/sriov-cni:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/sriov-network-device-plugin:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/sriov-network-operator:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/sriov-network-operator-config-daemon:network-operator-v25.7.0" \
    "nvcr.io/nvidia/mellanox/sriov-network-operator-webhook:network-operator-v25.7.0" \
    "ghcr.io/k8snetworkplumbingwg/plugins:v1.6.2-update.1" \
    "ghcr.io/k8snetworkplumbingwg/multus-cni:v4.1.0" \
    "ghcr.io/mellanox/nvidia-k8s-ipam:v0.2.0" \
    "ghcr.io/zalando/postgres-operator:v1.14.0" \
    "ghcr.io/zalando/postgres-operator/logical-backup:v1.13.0" \
    "ghcr.io/zalando/spilo-17:4.0-p2" \
    "registry.opensource.zalan.do/acid/pgbouncer:master-32" \
    "registry.k8s.io/prometheus-adapter/prometheus-adapter:v0.12.0" \
    "docker.io/grafana/promtail:3.5.1" \
    "ghcr.io/kubeflow/spark-operator/controller:2.3.0" \
  -o "cm_kubernetes_setup_images_kube_1.31.tar"
}

pull_local_path_provisioner_images() {
  echo
  echo "Pulling local-path-provisioner:0.0.31 images..."
  docker pull "docker.io/rancher/local-path-provisioner:v0.0.31"
}

save_local_path_provisioner_images() {
  echo
  echo "Saving local-path-provisioner:0.0.31 images to the archive"

  docker save \
    "docker.io/rancher/local-path-provisioner:v0.0.31" \
  -o "local-path-provisioner_0.0.31_images.tar"
}

pull_cm_kubernetes_permissions_manager_images() {
  echo
  echo "Pulling cm-kubernetes-permissions-manager:0.6.6 images..."
  docker pull "docker.io/brightcomputing/cm-kubernetes-permissions-manager-controller:0.6.6"
}

save_cm_kubernetes_permissions_manager_images() {
  echo
  echo "Saving cm-kubernetes-permissions-manager:0.6.6 images to the archive"

  docker save \
    "docker.io/brightcomputing/cm-kubernetes-permissions-manager-controller:0.6.6" \
  -o "cm-kubernetes-permissions-manager_0.6.6_images.tar"
}

pull_cm_jupyter_kernel_operator_images() {
  echo
  echo "Pulling cm-jupyter-kernel-operator:0.3.7 images..."
  docker pull "docker.io/brightcomputing/cm-jupyter-kernel-operator-controller:0.3.7"
  docker pull "docker.io/brightcomputing/cm-jupyter-kernel-operator-sidecar:0.3.7"
}

save_cm_jupyter_kernel_operator_images() {
  echo
  echo "Saving cm-jupyter-kernel-operator:0.3.7 images to the archive"

  docker save \
    "docker.io/brightcomputing/cm-jupyter-kernel-operator-controller:0.3.7" \
    "docker.io/brightcomputing/cm-jupyter-kernel-operator-sidecar:0.3.7" \
  -o "cm_jupyter_kernel_operator_0.3.7_images.tar"
}

pull_mpi_operator_images() {
  echo
  echo "Pulling mpi-operator:0.6.0 images..."
  docker pull "docker.io/mpioperator/mpi-operator:0.6.0"
}

save_mpi_operator_images() {
  echo
  echo "Saving mpi-operator:0.6.0 images to the archive"

  docker save \
    "docker.io/mpioperator/mpi-operator:0.6.0" \
  -o "mpi-operator_0.6.0_images.tar"
}

prepare_docker

pull_kubeadm_images
pull_cm_kubernetes_setup_images
pull_local_path_provisioner_images
pull_cm_kubernetes_permissions_manager_images
pull_cm_jupyter_kernel_operator_images
pull_mpi_operator_images

mkdir k8s-images
pushd k8s-images || exit 1

save_kubeadm_images
save_cm_kubernetes_setup_images
save_local_path_provisioner_images
save_cm_kubernetes_permissions_manager_images
save_cm_jupyter_kernel_operator_images
save_mpi_operator_images

popd || exit 1
