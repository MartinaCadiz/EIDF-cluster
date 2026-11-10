#!/usr/bin/env bash
# Show a job's logs from the beginning.
#   scripts/logs.sh <job>          print full log (paged with less)
#   scripts/logs.sh <job> -f       follow live (ctrl-c stops watching, job keeps running)
#   scripts/logs.sh <job> --save   save to logs/<job>.log
source "$(dirname "$0")/_common.sh"

need_arg "${1:-}" 'logs.sh <job> [-f|--save]'
JOB="$1"; MODE="${2:-}"

case "$MODE" in
  -f)
    k logs -f "job/$JOB" ;;
  --save)
    mkdir -p "$REPO_DIR/logs"
    OUT="$REPO_DIR/logs/$JOB.log"
    k logs --timestamps "job/$JOB" > "$OUT"
    echo "saved: $OUT ($(wc -l < "$OUT") lines)" ;;
  "")
    k logs "job/$JOB" | less ;;
  *)
    echo "unknown option: $MODE" >&2; exit 1 ;;
esac
