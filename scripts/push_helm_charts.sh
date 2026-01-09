#!/usr/bin/env bash
set -eu -o pipefail

registry="master.cm.cluster:5000"
registry_user=""
registry_password=""
helm_logged_in=false
ca_file=""
use_ca_file=true

for i in "$@"; do
  case $i in
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
    --ca-file=*)
      ca_file="${1#*=}"
      shift
      ;;
    --no-ca-file)
      use_ca_file=false
      shift
      ;;
    -h|--help)
      echo "Use $0 -r=<registry> [--ca-file=<path>] [--no-ca-file] to push prepared helm charts to registry."
      echo "Default registry is 'master.cm.cluster:5000'"
      echo "Default ca-file is '/etc/containerd/certs.d/<registry>/ca.crt'"
      echo "--no-ca-file disables the use of a CA file"
      echo "Use options '-u=<username> -p=<password>' for helm chart registry login if required"
      exit 0
      ;;
    *)
      echo "Unknown option $i"
      exit 1
      ;;
  esac
done

prepare_helm() {
  local ca_file_option="$1"
  if [ -n "$registry_user" ] && [ -n "$registry_password" ]; then
    # shellcheck disable=SC2086
    helm registry login "$registry" -u "$registry_user" -p "$registry_password" $ca_file_option
    helm_logged_in=true
  elif [ -n "$registry_user" ] || [ -n "$registry_password" ]; then
    echo "Incomplete registry credentials provided"
    exit 1
  fi
}

logout_helm() {
  if [ $helm_logged_in = true ]; then
    helm registry logout "$registry"
  fi
}
trap logout_helm EXIT

push_charts() {
  local ca_file_option="$1"
  for chart in *.tgz; do
    echo "Uploading $chart..."
    # shellcheck disable=SC2086
    helm push "$chart" "oci://$registry/helm-charts" $ca_file_option
  done
}

if $use_ca_file; then
  if [ -z "$ca_file" ]; then
    if [ -f "/etc/containerd/certs.d/$registry/ca.crt" ]; then
      ca_file="/etc/containerd/certs.d/$registry/ca.crt"
    elif [ -f "/etc/docker/certs.d/$registry/ca.crt" ]; then
      ca_file="/etc/docker/certs.d/$registry/ca.crt"
    else
      echo "CA file is not found for registry '$registry'"
      exit 1
    fi
  fi
  ca_file_option="--ca-file $ca_file"
else
  ca_file_option=""
fi

pushd helm-charts || exit 1
prepare_helm "$ca_file_option"
push_charts "$ca_file_option"
popd || exit 1
