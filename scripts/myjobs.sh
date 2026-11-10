#!/usr/bin/env bash
# List only your jobs and pods (the namespace is shared with the whole project).
source "$(dirname "$0")/_common.sh"

echo "== jobs =="
k get jobs -l "eidf/user=${EIDF_USER}"
echo
echo "== pods =="
k get pods -l "eidf/user=${EIDF_USER}"
