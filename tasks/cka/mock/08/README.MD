# CKA Mock Exam 08

## Cluster Info

| Cluster | Context |
|---------|---------|
| cluster1 | cluster1-admin@cluster1 |

## Tasks (100 pts, 120 min)

| # | Topic | Description | Pts |
|---|-------|-------------|-----|
| 1 | Helm | Add repo `ingress-nginx` (`https://kubernetes.github.io/ingress-nginx`). Search for `ingress-nginx`, save to `artifacts/1/search.txt`. Install release `web-ingress` in `helm-repo-ns` with `--set controller.service.type=NodePort` | 4 |
| 2 | CRD/CR | CRD `alerts.monitoring.example.com` exists. Run `kubectl explain alert.spec` and save to `artifacts/2/spec.txt`. Create CR `critical-alert` in `alert-ns`: severity=critical, message="CPU threshold exceeded", recipient=ops-team | 4 |
| 3 | Control Plane | Static pod `extra-etcd` at `/etc/kubernetes/manifests/extra-etcd.yaml` is CrashLoopBackOff. `--listen-peer-urls` port=2381 but `--initial-advertise-peer-urls` port=2382 (mismatch). Fix both to 2381. Also fix `--initial-cluster` to 2381. `--data-dir=/var/lib/etcd-extra-wrong` fix to `/var/lib/etcd-extra` | 7 |
| 4 | Sidecar Adapter | Create Pod `adapter-pod` in `adapter-ns`: main container nginx writes `/var/log/nginx/access.log`, sidecar busybox reads and prefixes `[ADAPTED]` to `/var/log/adapted/output.log`. Two shared volumes: `raw-logs`, `adapted-logs` | 5 |
| 5 | HPA Advanced | Deployment `api-service` in `hpa-adv-ns`. Create HPA `api-hpa` (autoscaling/v2): min=3, max=15, CPU 50% AND memory 70%. Behavior: scaleUp stabilization=0 Percent/100/15s, scaleDown stabilization=600 selectPolicy=Min | 6 |
| 6 | NP Egress | Pod `egress-pod` in `egress-ctl-ns`. Create NetworkPolicy: deny all egress, allow to (a) NS `backend-ns` (label env=backend) port 8080, (b) DNS 53 TCP+UDP, (c) CIDR 10.0.0.0/8 port 443 | 6 |
| 7 | Gateway Multi-Route | Gateway `shared-gw` in `gw-multi-ns` (HTTP port 80) pre-exists. Create 3 HTTPRoutes: `/users`->users-svc:80, `/orders`->orders-svc:80, host `products.cluster1.local`->products-svc:80 | 5 |
| 8 | Scheduling | Deployment `heavy-app` (3 replicas, cpu=2, memory=4Gi) Pending in `resource-debug-ns`. Save events to `artifacts/8/events.txt`. Scale to 1 replica, reduce to cpu=200m, memory=256Mi | 4 |
| 9 | Kubelet/Containerd | A worker node is NotReady. SSH to the node: containerd config has `disabled_plugins = ["cri"]`. Remove that line. Restart containerd and kubelet. Verify node Ready | 6 |
| 10 | CNI Fix | A node has podCIDR `10.244.4.0/24` outside Calico IPPool `10.244.0.0/23`. Save current IPPool to `artifacts/10/before.txt`. Expand IPPool CIDR to `10.244.0.0/16`. Save updated to `artifacts/10/after.txt` | 5 |
| 11 | Helm Upgrade | Chart at `/var/work/helm/webapp/`. Install `webapp-v1` in `helm-compare-ns` with defaults. Template with `prod-values.yaml` to `artifacts/11/prod-template.txt`. Upgrade release with prod values | 4 |
| 12 | NP Cross-NS AND+OR | Pod `backend` (app=backend,tier=data) in `cross-ns-pol`. Allow ingress from (a) pods tier=presentation in NS purpose=frontend (AND), (b) pods app=admin in NS purpose=admin (AND). Two `from` entries | 7 |
| 13 | Native Sidecar | Modify Deployment `web-deploy` in `native-sidecar-ns`: add init container with `restartPolicy: Always` named `log-shipper` (busybox, `tail -f /var/log/app/app.log`). Shared volume `app-logs` | 5 |
| 14 | CP Inspect | Save kube-apiserver flags: `--service-cluster-ip-range` to `artifacts/14/svc-cidr.txt`, `--etcd-servers` to `artifacts/14/etcd-url.txt`, `--authorization-mode` to `artifacts/14/auth-mode.txt` | 3 |
| 15 | CNI Inspect | Save node podCIDRs via jsonpath to `artifacts/15/node-cidrs.txt`. Save CNI config from `/etc/cni/net.d/` on master to `artifacts/15/cni-conf.txt` | 3 |
| 16 | LimitRange | Create LimitRange `strict-limits` in `limit-ns`: Container max cpu=500m memory=512Mi, min cpu=50m memory=64Mi. Create passing pod `limit-test-pod` (nginx, cpu=100m, memory=128Mi). Attempt over-limit pod, save error to `artifacts/16/error.txt` | 5 |
| 17 | Kubelet Certs | SSH to master. Save kubelet cert expiry (`openssl x509 -enddate -noout -in /var/lib/kubelet/pki/kubelet.crt`) to `artifacts/17/cert-expiry.txt`. Save last 50 lines `journalctl -u kubelet` to `artifacts/17/kubelet-journal.txt` | 3 |
| 18 | NP+HPA Compound | Deployment `scaled-web` in `compound-scale-ns`. Create HPA min=2 max=6 CPU 80%. Create NP: ingress from `role=loadbalancer` port 80, egress DNS 53 + `role=cache` port 6379 | 7 |
| 19 | Gateway+CNI | Create Gateway `secure-gw` in `gw-secure-ns` (HTTP port 80 + HTTPS port 443, TLS secret `secure-tls`). Create HTTPRoute `secure-route` host `secure.cluster1.local` -> `secure-backend-svc:80`. Save CNI config from master to `artifacts/19/cni-conf.txt` | 5 |
| 20 | CP+Kubelet | A worker node is NotReady. SSH: kubelet config has `clientCAFile=/etc/kubernetes/pki/ca-wrong.crt`. Fix to `ca.crt`. Restart kubelet. Verify Ready | 6 |
