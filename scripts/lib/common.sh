#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"
log() { printf '\033[1;34m[lab]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[lab warning]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[lab error]\033[0m %s\n' "$*" >&2; exit 1; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
retry() { local tries="$1" delay="$2"; shift 2; local n=1; until "$@"; do (( n >= tries )) && return 1; n=$((n + 1)); sleep "$delay"; done; }
wait_for_http() { local url="$1"; retry "${2:-60}" "${3:-2}" curl -fsS "$url" >/dev/null; }
load_env() { [[ -f .env ]] || cp .env.demo .env; set -a; source .env; set +a; }
compose() { docker compose -f docker-compose.yml "$@"; }
