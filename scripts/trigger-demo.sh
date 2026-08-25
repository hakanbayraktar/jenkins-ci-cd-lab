#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
load_env
cookie_jar="$(mktemp)"
trap 'rm -f "$cookie_jar"' EXIT
crumb="$(curl -fsS -c "$cookie_jar" -b "$cookie_jar" -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" http://localhost:8080/crumbIssuer/api/json)"
crumb_field="$(jq -r .crumbRequestField <<<"$crumb")"; crumb_value="$(jq -r .crumb <<<"$crumb")"
curl -fsS -c "$cookie_jar" -b "$cookie_jar" -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" -H "$crumb_field: $crumb_value" -X POST http://localhost:8080/job/flask-app-ci/build >/dev/null
log "CI build queued; waiting for a new CI build"
for _ in $(seq 1 90); do
  ci="$(curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" http://localhost:8080/job/flask-app-ci/lastBuild/api/json 2>/dev/null || true)"
  [[ -n "$ci" ]] && break
  sleep 2
done
[[ -n "${ci:-}" ]] || die "Jenkins did not start CI"
ci_number="$(jq -r .number <<<"$ci")"
while [[ "$(jq -r .building <<<"$ci")" == true ]]; do sleep 3; ci="$(curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" "http://localhost:8080/job/flask-app-ci/$ci_number/api/json")"; done
[[ "$(jq -r .result <<<"$ci")" == SUCCESS ]] || die "CI #$ci_number failed: http://localhost:8080/job/flask-app-ci/$ci_number/console"
log "CI #$ci_number: SUCCESS; waiting for automatic CD"
for _ in $(seq 1 120); do
  cd_build="$(curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" http://localhost:8080/job/flask-app-cd/lastBuild/api/json 2>/dev/null || true)"
  [[ -n "$cd_build" ]] && break
  sleep 2
done
[[ -n "${cd_build:-}" ]] || die "CI did not trigger CD"
cd_number="$(jq -r .number <<<"$cd_build")"
while [[ "$(jq -r .building <<<"$cd_build")" == true ]]; do sleep 3; cd_build="$(curl -fsS -u "$JENKINS_ADMIN_USER:$JENKINS_ADMIN_PASSWORD" "http://localhost:8080/job/flask-app-cd/$cd_number/api/json")"; done
[[ "$(jq -r .result <<<"$cd_build")" == SUCCESS ]] || die "CD #$cd_number failed: http://localhost:8080/job/flask-app-cd/$cd_number/console"
./scripts/verify.sh
printf '\nLAB STATUS: PASS\nCI: #%s SUCCESS\nCD: #%s SUCCESS\nApplication: http://localhost:8088\n' "$ci_number" "$cd_number"
