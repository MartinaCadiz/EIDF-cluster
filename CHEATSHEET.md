# kubectl cheat sheet (EIDF029)

All commands use `-n eidf029ns`. Tip: `alias k='kubectl -n eidf029ns'` in your `~/.bashrc`.

## Find things
```bash
kubectl -n eidf029ns get jobs
kubectl -n eidf029ns get pods
kubectl -n eidf029ns get pods -l eidf/user=$USER     # only yours
kubectl -n eidf029ns get pvc
kubectl -n eidf029ns describe pod <pod>              # events at the bottom: why it's Pending/failing
```

## Submit
```bash
kubectl -n eidf029ns create -f job.yaml
envsubst < job.yaml | kubectl -n eidf029ns create -f -   # fill ${VARS} from the shell first
```
Use `create` (not `apply`) with `generateName:`.

## Logs
```bash
kubectl -n eidf029ns logs job/<job>                  # whole log from the start
kubectl -n eidf029ns logs job/<job> > run.log        # save to a file (in the current folder)
kubectl -n eidf029ns logs job/<job> | less           # page: g top, G bottom, q quit
kubectl -n eidf029ns logs -f job/<job>               # follow live
kubectl -n eidf029ns logs <pod> --tail=200           # last 200 lines
kubectl -n eidf029ns logs <pod> --previous           # before the last restart
kubectl -n eidf029ns logs <pod> --timestamps
```

## Get inside
```bash
kubectl -n eidf029ns exec -it job/<job> -- bash      # or -- sh
kubectl -n eidf029ns describe job <job> | grep -A3 -i mounts   # where the PVC is mounted
kubectl -n eidf029ns cp <pod>:/mnt/data/file ./file  # copy out
kubectl -n eidf029ns cp ./file <pod>:/mnt/data/file  # copy in
```

## Stop
```bash
kubectl -n eidf029ns logs job/<job> > <job>.log      # save logs FIRST
kubectl -n eidf029ns delete job <job>                # deletes job, pods and logs
kubectl -n eidf029ns patch job <job> -p '{"spec":{"suspend":true}}'    # pause
kubectl -n eidf029ns patch job <job> -p '{"spec":{"suspend":false}}'   # resume
```
Never `delete jobs --all`: the namespace is shared with the whole project.
