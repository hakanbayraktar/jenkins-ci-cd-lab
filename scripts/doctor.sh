#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
for cmd in docker kind kubectl curl jq make git lsof; do command_exists "$cmd" || die "Missing prerequisite: $cmd"; done
docker info >/dev/null || die "Docker daemon is unavailable or this user cannot access it."
docker compose version >/dev/null || die "Docker Compose V2 is required."
port_is_owned_by_lab() {
  local port="$1"
  case "$port" in
    8080) [[ -n "$(docker compose ps --status running -q jenkins 2>/dev/null)" ]] && return 0 ;;
    8081|8082) [[ -n "$(docker compose ps --status running -q nexus 2>/dev/null)" ]] && return 0 ;;
  esac
  [[ "$port" == 8088 ]] && docker ps --format '{{.Names}} {{.Ports}}' | grep -Eq '^jenkins-ci-cd-lab-control-plane .*:8088->' && return 0
  return 1
}
for port in 8080 8081 8082 8088; do
  if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1 && ! port_is_owned_by_lab "$port"; then
    die "Port $port is already in use; stop the owning process or select a free host."
  fi
done
log "doctor: PASS (Docker, Compose, kind, kubectl and required ports are ready)"
