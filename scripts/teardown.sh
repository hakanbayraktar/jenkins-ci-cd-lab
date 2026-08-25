#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/lib/common.sh"
compose down
log "Lab services stopped; named data volumes are preserved."
