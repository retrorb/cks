# CKA Mock 06 — Troubleshooting + Storage + Workloads & Scheduling

**Duration:** 120 minutes | **Points:** 100 | **Clusters:** cluster1, cluster2

---

## Cluster Contexts

| Context | Cluster | Purpose |
|---------|---------|---------|
| `cluster1-admin@cluster1` | cluster1 | Main cluster — most tasks |
| `cluster2-admin@cluster2` | cluster2 | Broken components — tasks 1-2 |

---

## Tasks

### Troubleshooting (56 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 1 | cluster2 | Worker node is NotReady. Fix kubelet config path on the worker node (`/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`). | 5 |
| 2 | cluster2 | Static pod `extra-scheduler` in `kube-system` is not running due to a wrong config path. Fix the manifest at `/etc/kubernetes/manifests/extra-scheduler.yaml`. Correct config is at `/etc/kubernetes/scheduler-config.yaml`. | 5 |
| 3 | cluster1 | Backup etcd snapshot to `/var/work/tests/artifacts/3/etcd-backup.db` using `etcdctl`. | 6 |
| 4 | cluster1 | Pod `crash-app` in namespace `crash-ns` is in CrashLoopBackOff (command `/bin/wrong`). Fix it. | 5 |
| 5 | cluster1 | Deployment `bad-image-app` in namespace `image-ns` uses image `nginx:doesnotexist999`. Fix to `nginx:alpine`. | 4 |
| 6 | cluster1 | Service `no-ep-svc` in namespace `ep-ns` has selector `app=wrong-app`. Fix to `app=real-app`. | 5 |
| 7 | cluster1 | NetworkPolicy `block-egress` in namespace `dns-block` blocks all egress including DNS. Fix to allow port 53 UDP+TCP. | 5 |
| 8 | cluster1 | Ingress `broken-ingress` in namespace `ingress-fix` routes to backend port `9090`. Fix to port `80`. | 4 |
| 9 | cluster1 | A worker node has taint `broken=true:NoSchedule`. Remove it so `taint-test` deployment in `default` namespace can schedule. | 4 |
| 10 | cluster1 | Pod `oom-pod` in namespace `resource-ns` OOMKills due to memory limit `1Mi`. Increase memory limit to `64Mi`. | 4 |
| 11 | cluster1 | ConfigMap `app-config` in namespace `config-ns` has `DB_HOST: wrong-host`. Fix to `correct-db-host`. Restart `env-pod` to reflect the change. | 5 |
| 12 | cluster1 | Pod `stuck-pod` in namespace `affinity-ns` is Pending due to `nodeSelector: disk: ssd`. Remove the nodeSelector. | 4 |

### Storage (17 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 13 | cluster1 | Create StorageClass `fast-sc` (provisioner `kubernetes.io/no-provisioner`, `WaitForFirstConsumer`). Create PVC `fast-pvc` (2Gi) in namespace `storage-ns`. Create Pod `storage-pod` that mounts `fast-pvc` at `/data`. | 5 |
| 14 | cluster1 | PVC `stuck-pvc` in namespace `pvc-ns` is Pending (storageClassName `missing-sc`). Fix by creating StorageClass `missing-sc` (provisioner `kubernetes.io/no-provisioner`). | 4 |
| 15 | cluster1 | Create PV `local-pv` (5Gi, hostPath `/mnt/data`, ReadWriteOnce). Create PVC `local-pvc` in namespace `pv-ns` that binds to it. | 4 |
| 16 | cluster1 | PV `retain-pv` has reclaimPolicy `Delete`. Change it to `Retain`. Save the new policy value to `/var/work/tests/artifacts/16/policy.txt`. | 4 |

### Workloads & Scheduling (27 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 17 | cluster1 | Deployment `web-app` in namespace `rollout-ns` uses `nginx:1.25`. Perform a rolling update to `nginx:alpine`, then rollback. Save the current image name to `/var/work/tests/artifacts/17/image.txt`. | 6 |
| 18 | cluster1 | Create HPA `scalable-app-hpa` for Deployment `scalable-app` in namespace `hpa-ns`: min=1, max=5, target CPU utilization 50%. | 5 |
| 19 | cluster1 | Deployment `affinity-app` in namespace `schedule-ns`: add nodeAffinity (prefer `zone=primary`), add CPU limit `200m` and memory limit `256Mi`, add LivenessProbe (HTTP GET `/healthz` port `8080`, periodSeconds `10`). | 8 |
| 20 | cluster1 | Create ConfigMap `app-cm` (`DB_HOST=prod-db`) and Secret `app-secret` (`DB_PASS=s3cr3t`) in namespace `config-app-ns`. Create Pod `config-pod` (nginx) with both as env vars. Save `kubectl exec config-pod -- env` output to `/var/work/tests/artifacts/20/env.txt`. | 8 |

---

## etcd Backup Reference

```bash
ETCDCTL_API=3 etcdctl snapshot save /path/to/backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```
