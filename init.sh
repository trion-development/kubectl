#!/usr/bin/env bash
set -e

NAMESPACE=${PLUGIN_NAMESPACE:-${NAMESPACE:-default}}
KUBERNETES_USER=${PLUGIN_KUBERNETES_USER:-${KUBERNETES_USER:-default}}
KUBERNETES_TOKEN=${PLUGIN_KUBERNETES_TOKEN:-${KUBERNETES_TOKEN}}
KUBERNETES_SERVER=${PLUGIN_KUBERNETES_SERVER:-${KUBERNETES_SERVER:-kubernetes.default}}
KUBERNETES_CERT=${PLUGIN_KUBERNETES_CERT:-${KUBERNETES_CERT:-""}}
KUBERNETES_CA=${PLUGIN_KUBERNETES_CA:-${KUBERNETES_CA:-""}}

kubectl config set-credentials default --token="${KUBERNETES_TOKEN}"

if [ -n "${KUBERNETES_CA}" ]; then
  echo "${KUBERNETES_CA}" > ca.crt
  kubectl config set-cluster default --server="${KUBERNETES_SERVER}" --certificate-authority=ca.crt
elif [ -n "${KUBERNETES_CERT}" ]; then
  echo "${KUBERNETES_CERT}" | base64 -d > ca.crt
  kubectl config set-cluster default --server="${KUBERNETES_SERVER}" --certificate-authority=ca.crt
else
  echo "WARNING: Using untrusted connection to cluster"
  kubectl config set-cluster default --server="${KUBERNETES_SERVER}" --insecure-skip-tls-verify=true
fi

kubectl config set-context default --cluster=default --user="${PLUGIN_KUBERNETES_USER}"
kubectl config use-context default