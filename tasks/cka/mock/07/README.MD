# CKA Mock 07 — Helm + CNI + Gateway API + NetworkPolicy + Troubleshooting

**Duration:** 120 minutes | **Points:** 100 | **Clusters:** cluster1

---

## Cluster Contexts

| Context | Cluster | Purpose |
|---------|---------|---------|
| `cluster1-admin@cluster1` | cluster1 | Single cluster — all tasks |

---

## Tasks

### Helm & Application Packaging (18 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 1 | cluster1 | Install the local Helm chart at `/var/work/helm/analytics/` as release `analytics` in namespace `helm-install-ns` with `--set image.tag=v2.1,service.port=9090`. | 4 |
| 9 | cluster1 | Release `metrics-dash` is deployed in namespace `helm-tpl-ns`. Template the chart at `/var/work/helm/metrics-dash/` using `custom-values.yaml` and save output to `/var/work/tests/artifacts/9/template.txt`. Save the currently deployed image to `/var/work/tests/artifacts/9/deployed-image.txt`. | 5 |
| 14 | cluster1 | Release `broken-release` in namespace `helm-fix-ns` is at revision 3 with `replicas=0`. Rollback to revision 2. Save `helm history` output to `/var/work/tests/artifacts/14/history.txt`. | 4 |

### CNI & Networking (12 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 2 | cluster1 | Identify the CNI plugin name and save it to `/var/work/tests/artifacts/2/cni-name.txt`. Save the cluster pod CIDR from the `kubeadm-config` ConfigMap to `/var/work/tests/artifacts/2/pod-cidr.txt`. | 3 |
| 17 | cluster1 | Save all node podCIDRs using jsonpath to `/var/work/tests/artifacts/17/node-cidrs.txt`. Save the Calico IPPool YAML to `/var/work/tests/artifacts/17/ippool.txt`. | 4 |

### CRD & Custom Resources (5 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 3 | cluster1 | CRD `monitors.observability.example.com` exists. Run `kubectl explain monitor.spec` and save to `/var/work/tests/artifacts/3/explain.txt`. Create CR `prod-monitor` in namespace `monitor-ns` with `interval: 30s` and `target: api-server`. | 5 |

### Kubelet & Node (10 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 4 | cluster1 | SSH to a worker node and save `/var/lib/kubelet/config.yaml` to `/var/work/tests/artifacts/4/kubelet-config.txt`. Extract the `cgroupDriver` value to `/var/work/tests/artifacts/4/cgroup-driver.txt`. Save the containerd `SystemdCgroup` value to `/var/work/tests/artifacts/4/containerd-cgroup.txt`. | 4 |
| 18 | cluster1 | A worker node's kubelet is failing due to a wrong `tlsCertFile` path in `/var/lib/kubelet/config.yaml`. Fix the cert path, restart kubelet, and verify the node is Ready. | 6 |

### Pods & Containers (9 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 5 | cluster1 | Create Pod `log-aggregator` in namespace `sidecar-ns` with main container `app` (nginx:alpine) and sidecar `log-collector` (busybox, `tail -f /var/log/app/access.log`). Share volume `log-vol` at `/var/log/app`. | 5 |
| 13 | cluster1 | Add init container `init-wait` to Deployment `main-deploy` in namespace `init-ns` that waits for `db-svc` DNS resolution before starting. | 4 |

### NetworkPolicy (17 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 6 | cluster1 | In namespace `netpol-deny-ns`: create a deny-all ingress NetworkPolicy, then create a policy allowing ingress from pods with `role=api` on port 80 only. | 5 |
| 12 | cluster1 | In namespace `netpol-and-ns`: create a NetworkPolicy allowing ingress to `db-pod` (role=db) ONLY from pods with `role=api` AND in namespaces with label `env=production` (single `from` entry with both selectors — AND logic). | 6 |
| 19 | cluster1 | Create Pod `secure-logger` in namespace `compound-ns` (main: nginx port 80, sidecar: busybox tail, shared volume). Create a NetworkPolicy allowing ingress on port 80 from `role=frontend` only, with egress for DNS (port 53). | 6 |

### HPA & Scaling (13 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 7 | cluster1 | Deployment `worker-app` in namespace `hpa-behavior-ns`. Create HPA `worker-hpa`: min=2, max=10, CPU 60%, scaleDown stabilization=300s with Percent/10/60s policy, scaleUp with Pods/4/60s policy. | 7 |
| 20 | cluster1 | Deployment `gw-backend` in namespace `final-gw-ns`. Create HPA min=1, max=8, CPU 70%. Create Gateway + HTTPRoute for `app.cluster1.local`. Save status to `/var/work/tests/artifacts/20/status.txt`. | 6 |

### Scheduling & Quotas (10 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 8 | cluster1 | Pod `heavy-pod` in namespace `quota-ns` is Pending because requests exceed ResourceQuota. Reduce requests to `cpu=200m, memory=256Mi`. | 5 |
| 16 | cluster1 | Create ResourceQuota `team-quota` in namespace `team-ns` (pods=10, cpu=2, memory=2Gi). Create LimitRange `team-limits` (default cpu=100m, memory=128Mi). Create pod `quota-test-pod` (nginx, no explicit resources) and verify defaults are applied. | 5 |

### Control Plane & etcd (11 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 10 | cluster1 | Static pod `/etc/kubernetes/manifests/extra-apiserver.yaml` is CrashLoopBackOff due to wrong etcd port `2399`. Fix to `2379`. Save `crictl ps` output to `/var/work/tests/artifacts/10/crictl.txt`. | 6 |
| 15 | cluster1 | Save `etcdctl endpoint health` to `/var/work/tests/artifacts/15/health.txt` and `etcdctl member list` to `/var/work/tests/artifacts/15/members.txt` using certs from the kube-apiserver manifest. | 5 |

### Gateway API (5 pts)

| # | Context | Task | Pts |
|---|---------|------|-----|
| 11 | cluster1 | GatewayClass `nginx-gw` exists. Create Gateway `api-gateway` in namespace `gw-ns` (HTTP port 80). Create HTTPRoute `api-route`: host `api.cluster1.local`, path `/` -> `api-backend-svc:8080`. | 5 |

---

## etcd Reference

```bash
ETCDCTL_API=3 etcdctl endpoint health \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```
