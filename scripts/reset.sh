#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
compose down -v --remove-orphans || true
if kind get clusters | grep -qx jenkins-ci-cd-lab; then kind delete cluster --name jenkins-ci-cd-lab; fi
rm -f generated/jenkins-kubeconfig
log "Removed only jenkins-ci-cd-lab resources."
