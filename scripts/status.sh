#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
compose ps || true
kind get clusters || true
kubectl get nodes || true
kubectl -n jenkins-lab get all 2>/dev/null || true
curl -fsS http://localhost:8088/version 2>/dev/null || true
