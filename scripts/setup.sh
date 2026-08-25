#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
./scripts/doctor.sh
load_env
prepare_kind_config() {
  local host_os app_listen_address
  host_os="$(uname -s)"
  app_listen_address="${APP_LISTEN_ADDRESS:-}"
  if [[ -z "$app_listen_address" ]]; then
    case "$host_os" in
      Linux) app_listen_address="0.0.0.0" ;;
      Darwin) app_listen_address="127.0.0.1" ;;
      *) app_listen_address="127.0.0.1"; warn "Unknown host OS ($host_os); binding Flask only to loopback." ;;
    esac
  fi
  [[ "$app_listen_address" == "127.0.0.1" || "$app_listen_address" == "0.0.0.0" ]] || die "APP_LISTEN_ADDRESS must be 127.0.0.1 or 0.0.0.0"
  mkdir -p generated
  sed "s/listenAddress: \"127.0.0.1\"/listenAddress: \"${app_listen_address}\"/" kind/kind-config.yaml > generated/kind-config.yaml
  export APP_LISTEN_ADDRESS="$app_listen_address"
  log "Application host binding: ${APP_LISTEN_ADDRESS} (${host_os})"
}
prepare_kind_config
if ! kind get clusters | grep -qx jenkins-ci-cd-lab; then
  log "Creating kind cluster"
  kind create cluster --name jenkins-ci-cd-lab --config generated/kind-config.yaml
else
  log "Reusing kind cluster (existing NodePort binding is unchanged; use make reset to apply a changed binding)"
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
if [[ "$(uname -s)" == Linux && "$APP_LISTEN_ADDRESS" == "0.0.0.0" ]]; then
  printf 'Linux remote app access: http://<server-ip>:8088 (allow TCP/8088 in the host firewall/security group)\n'
fi
