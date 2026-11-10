#!/usr/bin/env bash
# Open a shell inside a running job (e.g. to look at the PVC).
#   scripts/shell.sh <job>
# 'exit' leaves the shell; the job keeps running.
source "$(dirname "$0")/_common.sh"

need_arg "${1:-}" 'shell.sh <job>'
echo "PVC is mounted at: $MOUNT_PATH"
if k exec "job/$1" -- sh -c 'command -v bash' >/dev/null 2>&1; then
  k exec -it "job/$1" -- bash
else
  k exec -it "job/$1" -- sh
fi
