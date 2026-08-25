#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
load_env
docker info >/dev/null
running_services="$(compose ps --status running --services)"
grep -qx jenkins <<<"$running_services"
grep -qx nexus <<<"$running_services"
kind get clusters | grep -qx jenkins-ci-cd-lab
[[ "$(kubectl get nodes --no-headers | awk '$2 == "Ready" {n++} END {print n+0}')" -ge 2 ]] || die "kind does not have two Ready nodes"
wait_for_http http://localhost:8081/service/rest/v1/status 5 2
curl -fsS -u "$NEXUS_ADMIN_USER:$NEXUS_ADMIN_PASSWORD" http://localhost:8081/service/rest/v1/repositories | jq -e '.[] | select(.name == "docker-hosted")' >/dev/null
curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" http://localhost:8080/job/flask-app-ci/api/json >/dev/null
curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" http://localhost:8080/job/flask-app-cd/api/json >/dev/null
kubectl -n jenkins-lab rollout status deployment/flask-app --timeout=20s
[[ "$(kubectl -n jenkins-lab get deployment flask-app -o jsonpath='{.status.readyReplicas}')" == 2 ]] || die "Application does not have two Ready replicas"
wait_for_http http://localhost:8088/health 10 2
version="$(curl -fsS http://localhost:8088/version | jq -r .version)"
[[ "$version" != development && "$version" != placeholder && -n "$version" ]] || die "Application version is not an immutable deployed tag"
printf 'make verify: PASS (application version %s)\n' "$version"
