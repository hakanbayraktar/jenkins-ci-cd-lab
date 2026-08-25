#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
load_env
api() { curl -fsS -u "$NEXUS_ADMIN_USER:$NEXUS_ADMIN_PASSWORD" -H 'Content-Type: application/json' "$@"; }
log "Waiting for Nexus REST API"
wait_for_http http://localhost:8081/service/rest/v1/status 90 2 || die "Nexus did not become ready"
initial_password="$(docker exec jenkins-ci-cd-lab-nexus-1 sh -c 'cat /nexus-data/admin.password 2>/dev/null || true')"
if ! curl -fsS -u "$NEXUS_ADMIN_USER:$NEXUS_ADMIN_PASSWORD" http://localhost:8081/service/rest/v1/status >/dev/null && [[ -n "$initial_password" ]]; then
  log "Setting the intentionally public demo Nexus admin password"
  curl -fsS -u "admin:$initial_password" -H 'Content-Type: text/plain' -X PUT --data "$NEXUS_ADMIN_PASSWORD" http://localhost:8081/service/rest/v1/security/users/admin/change-password >/dev/null
fi
active="$(api http://localhost:8081/service/rest/v1/security/realms/active)"
if ! jq -e '.[] == "DockerToken"' <<<"$active" >/dev/null; then
  jq -c '. + ["DockerToken"] | unique' <<<"$active" | api -X PUT --data-binary @- http://localhost:8081/service/rest/v1/security/realms/active >/dev/null
fi
if ! api http://localhost:8081/service/rest/v1/repositories | jq -e '.[] | select(.name == "docker-hosted")' >/dev/null; then
  api -X POST --data '{"name":"docker-hosted","online":true,"storage":{"blobStoreName":"default","strictContentTypeValidation":true,"writePolicy":"ALLOW"},"cleanup":null,"component":{"proprietaryComponents":false},"docker":{"v1Enabled":false,"forceBasicAuth":false,"httpPort":8082}}' http://localhost:8081/service/rest/v1/repositories/docker/hosted >/dev/null
fi
if ! api http://localhost:8081/service/rest/v1/security/roles/jenkins-ci-role >/dev/null 2>&1; then
  api -X POST --data '{"id":"jenkins-ci-role","name":"Jenkins CI Docker hosted","description":"TRAINING ONLY: push and pull docker-hosted","privileges":["nx-repository-view-docker-docker-hosted-*"],"roles":[]}' http://localhost:8081/service/rest/v1/security/roles >/dev/null
fi
if ! api http://localhost:8081/service/rest/v1/security/users | jq -e --arg id "$NEXUS_CI_USER" '.[] | select(.userId == $id)' >/dev/null; then
  api -X POST --data "{\"userId\":\"$NEXUS_CI_USER\",\"firstName\":\"Jenkins\",\"lastName\":\"CI\",\"emailAddress\":\"jenkins-ci@example.invalid\",\"password\":\"$NEXUS_CI_PASSWORD\",\"status\":\"active\",\"roles\":[\"jenkins-ci-role\"]}" http://localhost:8081/service/rest/v1/security/users >/dev/null
fi
log "Nexus bootstrap: PASS"
