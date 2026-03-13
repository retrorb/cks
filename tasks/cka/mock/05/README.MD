# CKA Mock Exam 05 — Troubleshooting (30%)

**Cluster:** `cluster1-admin@cluster1`
**Time:** 120 minutes
**Total points:** 100

Set the context at the start of each task:
```bash
kubectl config use-context cluster1-admin@cluster1
```

---

## Task 1 (5 pts)
A worker node has a NoSchedule taint `broken=true:NoSchedule` which prevents pods from being scheduled on it.
**Remove** the taint so the node becomes schedulable again.

---

## Task 2 (6 pts)
A static pod manifest exists at `/etc/kubernetes/manifests/broken-scheduler.yaml`.
It is configured with flag `--config=/nonexistent/scheduler-config.yaml` which does not exist.
**Fix** the manifest to use the correct config path `/etc/kubernetes/scheduler-config.yaml`.

---

## Task 3 (5 pts)
A Pod named `crash-app` in namespace `crash-ns` is in CrashLoopBackOff.
The pod is configured with command `/bin/wrong` which does not exist.
**Fix** the pod so it runs successfully. You can change the command to `/bin/sh -c "sleep 3600"`.

---

## Task 4 (4 pts)
A Deployment named `bad-image-app` in namespace `image-ns` uses image `nginx:doesnotexist999` which cannot be pulled.
**Fix** the image to `nginx:alpine` so the pods can start.

---

## Task 5 (5 pts)
A Deployment named `oom-app` in namespace `resource-ns` keeps getting OOMKilled because the memory limit is set to `1Mi`.
**Increase** the memory limit to at least `64Mi` so the pods can run successfully.

---

## Task 6 (5 pts)
A PVC named `stuck-pvc` in namespace `pvc-ns` is stuck in Pending state because it references a StorageClass `missing-sc` that does not exist.
**Fix** the issue by creating a StorageClass named `missing-sc` with provisioner `kubernetes.io/no-provisioner`.

---

## Task 7 (4 pts)
Install metrics-server if not present, then run:
```bash
kubectl top pods -n monitor-ns --sort-by=cpu
```
Save the output to `/var/work/tests/artifacts/7/top-pods.txt`.

---

## Task 8 (3 pts)
Run `kubectl top nodes` and save the output to `/var/work/tests/artifacts/8/top-nodes.txt`.

---

## Task 9 (4 pts)
A Pod named `log-pod` in namespace `log-ns` is running and writing log messages.
Save the **last 50 lines** of its logs to `/var/work/tests/artifacts/9/logs.txt`.

---

## Task 10 (4 pts)
A Pod named `multi-pod` in namespace `multi-ns` has two containers: `main` (nginx) and `sidecar` (busybox writing logs).
Save the logs of the `sidecar` container to `/var/work/tests/artifacts/10/sidecar.txt`.

---

## Task 11 (5 pts)
A Pod named `restart-pod` in namespace `restart-ns` keeps crashing (the container exits after a few seconds).
Save the logs of the **previous** (crashed) container instance to `/var/work/tests/artifacts/11/prev-logs.txt`.

---

## Task 12 (5 pts)
A Service named `wrong-port-svc` in namespace `svc-ns` has an incorrect `targetPort` of `9999`.
The backend pod actually listens on port `8080`.
**Fix** the Service so `targetPort` is `8080`.

---

## Task 13 (6 pts)
A Service named `no-ep-svc` in namespace `ep-ns` has selector `app=wrong-app`, but the actual pods have label `app=real-app`.
**Fix** the Service selector so it targets `app=real-app`.

---

## Task 14 (4 pts)
An Ingress named `broken-ingress` in namespace `ingress-fix` routes traffic to backend port `9090`.
The actual service listens on port `80`.
**Fix** the Ingress so it routes to port `80`.

---

## Task 15 (6 pts)
A Pod named `no-dns-pod` in namespace `dns-block` cannot resolve DNS because a NetworkPolicy named `block-egress` blocks all egress traffic (including DNS on port 53).
**Fix** the NetworkPolicy to allow egress on port `53` (both UDP and TCP) so DNS resolution works.

---

## Task 16 (5 pts)
A node has a `NoExecute` taint `maintenance=true:NoExecute` which evicts pods.
**Remove** the taint and uncordon the node.

---

## Task 17 (5 pts)
A Pod named `env-pod` in namespace `config-ns` reads its `DB_HOST` environment variable from ConfigMap `app-config`.
The ConfigMap has the wrong value `wrong-host` for key `DB_HOST`.
**Fix** the ConfigMap so `DB_HOST` has value `correct-db-host`.
Then recreate the pod so it picks up the new value.

---

## Task 18 (5 pts)
A Pod named `secret-pod` in namespace `secret-ns` fails to start because it references a key `db-password` in Secret `app-secret`, but the Secret only has key `wrong-key`.
**Fix** the Secret by adding key `db-password` with any non-empty value.

---

## Task 19 (5 pts)
A Pod named `stuck-pod` in namespace `affinity-ns` is stuck in `Pending` state because it has a `nodeSelector` for `disk: ssd`, but no nodes have this label.
**Fix** the pod by removing the `nodeSelector` so it can be scheduled.

---

## Task 20 (9 pts)
A Pod named `client-pod` in namespace `final-ns` cannot reach Service `backend-svc`.
There are two bugs:
1. Service `backend-svc` has selector `app=wrong` but the backend pods have label `app=backend`
2. NetworkPolicy `block-all` blocks all ingress to `backend-svc` pods

**Fix both issues** so `client-pod` can successfully curl `backend-svc`.

---

## Scoring

| Task | Points |
|------|--------|
| 1 | 5 |
| 2 | 6 |
| 3 | 5 |
| 4 | 4 |
| 5 | 5 |
| 6 | 5 |
| 7 | 4 |
| 8 | 3 |
| 9 | 4 |
| 10 | 4 |
| 11 | 5 |
| 12 | 5 |
| 13 | 6 |
| 14 | 4 |
| 15 | 6 |
| 16 | 5 |
| 17 | 5 |
| 18 | 5 |
| 19 | 5 |
| 20 | 9 |
| **Total** | **100** |
