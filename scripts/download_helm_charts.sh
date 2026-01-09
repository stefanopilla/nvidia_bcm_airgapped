#!/usr/bin/env bash
set -eu -o pipefail

if command -v "helm" &> /dev/null; then
  helm_executable="helm"
elif command -v "microk8s.helm" &> /dev/null; then
  helm_executable="microk8s.helm"
else
  helm_executable=""
fi

for i in "$@"; do
  case $i in
    --helm-executable=*)
      helm_executable="${i#*=}"
      shift # past argument=value
      ;;
    --helm-executable)
      helm_executable="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo "Use $0 --helm-executable=<name> to pull helm charts."
      if [ "$helm_executable" ]; then
        echo "Default helm executable is '$helm_executable'"
      fi
      exit 0
      ;;
    *)
      echo "Unknown option $i"
      exit 1
      ;;
  esac
done

check_helm_executable() {
  if ! [ "$helm_executable" ]; then
    echo "Helm executable is not found and not specified via argument" >&2
    exit 1
  elif ! command -v "$helm_executable" >/dev/null 2>&1; then
    echo "Helm executable '$helm_executable' is invalid" >&2
    exit 1
  fi
}

download_charts() {
  echo "Downloading helm charts..."
  eval " $helm_executable" pull alloy --repo https://grafana.github.io/helm-charts --version 1.2.1
  eval " $helm_executable" pull ceph-csi-rbd --repo https://ceph.github.io/csi-charts --version 3.15.0
  eval " $helm_executable" pull gpu-operator --repo https://helm.ngc.nvidia.com/nvidia --version v25.3.3
  eval " $helm_executable" pull k8s-nim-operator --repo https://helm.ngc.nvidia.com/nvidia --version 2.0.2
  eval " $helm_executable" pull kube-prometheus-stack --repo https://prometheus-community.github.io/helm-charts --version 77.6.2
  eval " $helm_executable" pull kube-state-metrics --repo https://prometheus-community.github.io/helm-charts --version 6.3.0
  eval " $helm_executable" pull kubernetes-dashboard --repo https://kubernetes.github.io/dashboard/ --version 7.13.0
  eval " $helm_executable" pull kyverno --repo https://kyverno.github.io/kyverno/ --version 3.5.1
  eval " $helm_executable" pull kyverno-policies --repo https://kyverno.github.io/kyverno/ --version 3.5.1
  eval " $helm_executable" pull loki --repo https://grafana.github.io/helm-charts --version 6.40.0
  eval " $helm_executable" pull oci://registry.k8s.io/lws/charts/lws --version v0.7.0
  eval " $helm_executable" pull metallb --repo https://metallb.github.io/metallb --version 0.15.2
  eval " $helm_executable" pull metrics-server --repo https://kubernetes-sigs.github.io/metrics-server/ --version 3.13.0
  eval " $helm_executable" pull network-operator --repo https://helm.ngc.nvidia.com/nvidia --version 25.7.0
  eval " $helm_executable" pull postgres-operator --repo https://opensource.zalando.com/postgres-operator/charts/postgres-operator --version 1.14.0
  eval " $helm_executable" pull prometheus-adapter --repo https://prometheus-community.github.io/helm-charts --version 5.1.0
  eval " $helm_executable" pull promtail --repo https://grafana.github.io/helm-charts --version 6.17.0
  eval " $helm_executable" pull spark-operator --repo https://kubeflow.github.io/spark-operator --version 2.3.0
}

check_helm_executable

mkdir helm-charts
pushd helm-charts || exit 1
download_charts
popd || exit 1
