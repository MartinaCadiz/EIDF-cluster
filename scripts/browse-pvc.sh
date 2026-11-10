#!/usr/bin/env bash
# Start a small pod that mounts your PVC and open a shell in it.
#   scripts/browse-pvc.sh           start (if needed) and open shell
#   scripts/browse-pvc.sh --delete  remove the browser pod when done
source "$(dirname "$0")/_common.sh"

NAME="${EIDF_USER}-pvc-browser"

if [[ "${1:-}" == "--delete" ]]; then
  k delete job "$NAME"
  exit 0
fi

if ! k get job "$NAME" >/dev/null 2>&1; then
  envsubst "$TEMPLATE_VARS" < "$REPO_DIR/templates/pvc-browser.yaml" | k create -f -
fi

echo "waiting for pod to start..."
k wait --for=condition=Ready pod -l "job-name=$NAME" --timeout=180s
echo "PVC is at $MOUNT_PATH. Remember: scripts/browse-pvc.sh --delete when done."
k exec -it "job/$NAME" -- sh
