#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
mkdir -p generated
kubectl config view --raw --minify --context kind-jenkins-ci-cd-lab > generated/jenkins-kubeconfig
sed -i.bak 's#https://127.0.0.1:[0-9]*#https://jenkins-ci-cd-lab-control-plane:6443#' generated/jenkins-kubeconfig
rm -f generated/jenkins-kubeconfig.bak
chmod 600 generated/jenkins-kubeconfig
