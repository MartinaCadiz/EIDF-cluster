#!/usr/bin/env bash
# Submit a GPU training job.
#   scripts/submit.sh <short-name> "<command to run inside the pod>"
# Example:
#   scripts/submit.sh baseline "cd code && pip install -r requirements.txt && python train.py --epochs 50"
# The command runs from MOUNT_PATH (your PVC), so paths are relative to the PVC.
source "$(dirname "$0")/_common.sh"

need_arg "${1:-}" 'submit.sh <short-name> "<command>"'
need_arg "${2:-}" 'submit.sh <short-name> "<command>"'

export JOB_NAME="$1"
export CMD="$2"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  envsubst "$TEMPLATE_VARS" < "$REPO_DIR/templates/gpu-job.yaml"
  exit 0
fi

JOB=$(envsubst "$TEMPLATE_VARS" < "$REPO_DIR/templates/gpu-job.yaml" | k create -f - -o name)
JOB=${JOB#job.batch/}
echo "submitted: $JOB"
echo "logs:      scripts/logs.sh $JOB -f"
