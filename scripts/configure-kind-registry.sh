#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
for node in $(kind get nodes --name jenkins-ci-cd-lab); do
  log "Configuring registry access on $node"
  docker exec "$node" mkdir -p /etc/containerd/certs.d/nexus:8082
  printf '%s\n' 'server = "http://nexus:8082"' '' '[host."http://nexus:8082"]' '  capabilities = ["pull", "resolve"]' '  skip_verify = true' | docker exec -i "$node" tee /etc/containerd/certs.d/nexus:8082/hosts.toml >/dev/null
done
