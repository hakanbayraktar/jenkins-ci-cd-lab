#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
load_env
kubectl apply -f k8s/namespace.yaml
kubectl -n jenkins-lab create secret docker-registry nexus-regcred \
  --docker-server=nexus:8082 --docker-username="$NEXUS_CI_USER" --docker-password="$NEXUS_CI_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
