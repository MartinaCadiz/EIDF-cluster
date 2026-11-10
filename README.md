# EIDF GPU cluster: quick-start for EIDF029

How to run training jobs on the EIDF GPU service (Kubernetes) from the EIDF029 project VM:
submit a job, watch its logs, get into the PVC, and stop runs cleanly.

Everything here runs **from the project VM** (where `kubectl` is already configured).
Our namespace is `eidf029ns` and the Kueue queue is `eidf029ns-user-queue`.

```
eidf-k8s-guide/
├── config.env.example     # your settings (copy to config.env)
├── templates/
│   ├── gpu-job.yaml       # GPU training job
│   └── pvc-browser.yaml   # tiny pod for looking inside your PVC
├── scripts/               # wrappers around kubectl
└── CHEATSHEET.md          # the raw kubectl commands
```

## 1. Setup (once)

```bash
git clone <this-repo> && cd eidf-k8s-guide
cp config.env.example config.env
kubectl -n eidf029ns get pvc        # find your PVC name
nano config.env                     # set PVC_NAME (and GPU type/resources if needed)
chmod +x scripts/*.sh
```

`config.env` is gitignored, so each person keeps their own.

If `envsubst` is missing: `sudo apt install gettext-base`.

## 2. How it works

- **Your code and data live on a PVC** (persistent volume). Pods are temporary;
  the PVC is what survives. Put your repo/data there and write outputs and checkpoints there.
- **A Job** asks for a pod with a GPU. Kueue queues it until resources are free.
- The pod mounts the PVC at `MOUNT_PATH` (default `/mnt/data`) and runs your command from there.
- When a job is deleted, its pod **and its logs** are deleted too. Save logs first
  (the scripts do this for you).

## 3. Daily workflow

```bash
# submit (command runs from the PVC root)
scripts/submit.sh baseline "cd my-project && python train.py --epochs 50"

# see your jobs and pods (namespace is shared, this filters to yours)
scripts/myjobs.sh

# logs from the beginning / live / saved to logs/<job>.log
scripts/logs.sh <job>
scripts/logs.sh <job> -f
scripts/logs.sh <job> --save

# shell inside a running job (to look at the PVC, check files, nvidia-smi...)
scripts/shell.sh <job>

# stop: saves logs, asks, then deletes
scripts/stop.sh <job>
scripts/stop.sh <job> --suspend      # pause instead, frees the GPU
scripts/stop.sh <job> --resume
```

Job names get a random suffix (e.g. `martina-baseline-x7k2p`); `submit.sh` prints the full name.

To check what will be submitted without submitting: `DRY_RUN=1 scripts/submit.sh test "python train.py"`.

## 4. Looking inside the PVC when no job is running

```bash
scripts/browse-pvc.sh            # starts a small pod and opens a shell in it
scripts/browse-pvc.sh --delete   # remove it when done (otherwise it holds resources)
```

Copy a file out to the VM (then open it in VS Code):
```bash
kubectl -n eidf029ns cp <pod-name>:/mnt/data/path/to/file ./file
```

## 5. Tips

- **Write your own log file to the PVC** (e.g. `python train.py 2>&1 | tee runs/exp1.log`).
  `kubectl logs` loses everything before a restart, and very long logs get rotated.
- **Save checkpoints to the PVC** so a killed job can resume.
- `PYTHONUNBUFFERED=1` is set in the template so `print()` shows up in the logs straight away.
- `/dev/shm` is enlarged in the template; increase `sizeLimit` if DataLoader workers crash with bus errors.
- Install packages in the command (`pip install -r requirements.txt && python ...`) or use your own image.
- GPU type is set with `GPU_PRODUCT` in `config.env`. Check the EIDF docs for the current list
  (e.g. `NVIDIA-A100-SXM4-40GB`, `NVIDIA-A100-SXM4-80GB`, `NVIDIA-H100-80GB-HBM3`).

## 6. Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| `unknown field "spec.template.metadata.eidf/user"` | A label isn't under `labels:`. Labels go in a `labels:` block in `metadata`. |
| Pod stays `Pending` | Queue is busy or you asked for a GPU type that's full. `kubectl -n eidf029ns describe pod <pod>` shows why. |
| Pod stuck `ContainerCreating` | PVC is ReadWriteOnce and already used by another pod. Use `scripts/shell.sh` on that job instead. |
| Logs start in the middle | Container restarted, or log was rotated. Use your own log file on the PVC. |
| `envsubst: command not found` | `sudo apt install gettext-base` |
| Placeholder left blank in yaml | Variable missing from `config.env`. Check with `DRY_RUN=1`. |

Raw commands for everything above: see [CHEATSHEET.md](CHEATSHEET.md).
