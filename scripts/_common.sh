#!/usr/bin/env bash
# Shared helpers: load config.env and define the k() shortcut.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${REPO_DIR}/config.env"

if [[ ! -f "$CONFIG" ]]; then
  echo "config.env not found. Run:  cp config.env.example config.env  and edit it." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$CONFIG"
set +a

# Only these variables get substituted in templates, so $ signs inside
# your training command are left alone.
# shellcheck disable=SC2016,SC2034
TEMPLATE_VARS='${EIDF_USER} ${QUEUE} ${PVC_NAME} ${MOUNT_PATH} ${IMAGE} ${GPU_PRODUCT} ${GPU_COUNT} ${CPU} ${MEMORY} ${JOB_NAME} ${CMD}'

k() { kubectl -n "$NAMESPACE" "$@"; }

need_arg() {
  if [[ -z "${1:-}" ]]; then
    echo "usage: $2" >&2
    exit 1
  fi
}
