#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
./scripts/doctor.sh
load_env
if ! kind get clusters | grep -qx jenkins-ci-cd-lab; then
  log "Creating kind cluster"
  kind create cluster --name jenkins-ci-cd-lab --config kind/kind-config.yaml
else
  log "Reusing kind cluster"
fi
./scripts/generate-jenkins-kubeconfig.sh
log "Starting Jenkins, Docker-in-Docker and Nexus"
compose up -d --build
./scripts/bootstrap-nexus.sh
./scripts/configure-kind-registry.sh
./scripts/create-k8s-secret.sh
wait_for_http http://localhost:8080/login 90 2 || die "Jenkins did not become ready"
retry 30 2 curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" http://localhost:8080/job/flask-app-ci/api/json >/dev/null || die "JCasC Job DSL did not create flask-app-ci"
retry 30 2 curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" http://localhost:8080/job/flask-app-cd/api/json >/dev/null || die "JCasC Job DSL did not create flask-app-cd"
docker exec jenkins-ci-cd-lab-jenkins-1 kubectl get nodes >/dev/null || die "Jenkins cannot access Kubernetes"
log "Lab is ready"
printf 'Jenkins: http://localhost:8080\nNexus: http://localhost:8081\nApp: http://localhost:8088 (available after make demo)\n'
