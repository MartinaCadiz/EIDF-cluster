#!/usr/bin/env bash
# Stop a job. Logs are saved to logs/<job>.log first, since deleting a job deletes them.
#   scripts/stop.sh <job>             save logs, then delete
#   scripts/stop.sh <job> --suspend   pause (keeps the job, frees the GPU)
#   scripts/stop.sh <job> --resume    resume a suspended job
source "$(dirname "$0")/_common.sh"

need_arg "${1:-}" 'stop.sh <job> [--suspend|--resume]'
JOB="$1"; MODE="${2:-}"

case "$MODE" in
  --suspend)
    k patch job "$JOB" -p '{"spec":{"suspend":true}}' ;;
  --resume)
    k patch job "$JOB" -p '{"spec":{"suspend":false}}' ;;
  "")
    "$REPO_DIR/scripts/logs.sh" "$JOB" --save || echo "(no logs to save)"
    read -r -p "delete job $JOB? [y/N] " ans
    [[ "$ans" == "y" ]] && k delete job "$JOB" ;;
  *)
    echo "unknown option: $MODE" >&2; exit 1 ;;
esac
