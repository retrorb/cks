# CKA Mock Exam 03 — Servicing and Networking (20%)

**Cluster:** `cluster1-admin@cluster1`
**Time:** 120 minutes
**Total points:** 100

Set the context at the start of each task:
```bash
kubectl config use-context cluster1-admin@cluster1
```

---

## Task 1 (3 pts)
A Deployment named `backend` already exists in namespace `app-1`.
Create a **ClusterIP** Service named `backend-service` in namespace `app-1` that exposes the `backend` Deployment on port **80**.

---

## Task 2 (5 pts)
Create a **Deployment** named `frontend` in namespace `web-app`:
- Image: `nginx:alpine`
- Replicas: `2`

Create a **NodePort** Service named `frontend-service` in namespace `web-app`:
- Exposes port `80`
- NodePort: `30080`

---

## Task 3 (3 pts)
A Pod named `api-pod` (image: `viktoruj/ping_pong:alpine`, listening on port `8080`) already exists in the `default` namespace.
Create a **LoadBalancer** Service named `api-lb` in the `default` namespace that:
- Exposes port `80`
- Forwards traffic to targetPort `8080`

---

## Task 4 (4 pts)
A StatefulSet named `db` (with label `app=db`) already exists in namespace `data`.
Create a **Headless** Service named `db-headless` in namespace `data`:
- `clusterIP: None`
- Selector: `app=db`
- Port: `3306`

---

## Task 5 (6 pts)
A Deployment named `broken-app` and a Service named `broken-service` already exist in namespace `fix-me`.
The Service is broken — it has the wrong selector (`app=wrong-label`) and has no endpoints.
**Fix** the `broken-service` so that it correctly targets the `broken-app` pods.

---

## Task 6 (4 pts)
In the `default` namespace:
1. Create a Pod named `endpoint-test` using image `nginx:alpine`
2. Create a Service named `endpoint-service` that exposes the pod on port `80`
3. Save the endpoint IP to `/var/work/tests/artifacts/6/endpoints.txt`

---

## Task 7 (5 pts)
Create a **deny-all ingress** NetworkPolicy named `deny-all` in namespace `policy-ns`:
- Applies to ALL pods in the namespace
- Blocks all ingress traffic

---

## Task 8 (6 pts)
A Pod named `server` (label `app=server`) exists in namespace `app-net`.
Pods `allowed-client` (label `role=client`) and `denied-client` (label `role=other`) exist in namespace `allowed-net`.

Create a NetworkPolicy named `allow-client-to-server` in namespace `app-net` that:
- Protects the `server` pod
- Allows ingress only from pods with label `role=client`
- Denies all other ingress

---

## Task 9 (6 pts)
A Pod named `secure-server` (label `app=secure-server`) exists in namespace `secure-ns`.
Namespace `trusted-ns` has label `team=trusted`. Namespace `untrusted-ns` has label `team=untrusted`.

Create a NetworkPolicy named `allow-trusted-namespace` in namespace `secure-ns` that:
- Allows ingress to `secure-server` only from namespaces with label `team=trusted`
- Denies ingress from all other namespaces

---

## Task 10 (7 pts)
A Pod named `restricted-pod` (label `app=restricted`) exists in namespace `restricted-ns`.
A Service named `allowed-target-svc` exists in namespace `allowed-target-ns`.

Create a NetworkPolicy named `restrict-egress` in namespace `restricted-ns` that:
- Denies all **ingress** to `restricted-pod`
- Allows **egress** only to:
  - Port `53` (UDP and TCP) for DNS
  - Port `80` to namespace `allowed-target-ns`
- Blocks all other egress

---

## Task 11 (4 pts)
Pre-existing: Deployment `ingress-app` and Service `ingress-app-svc` in namespace `ingress-ns`.

Create an Ingress named `main-ingress` in namespace `ingress-ns`:
- `ingressClassName: nginx`
- Host: `app.k8s.local`
- Path `/` → `ingress-app-svc:80`
- `pathType: Prefix`

---

## Task 12 (6 pts)
Pre-existing: Deployments `service-v1` and `service-v2` with their Services in namespace `multi-path-ns`.

Create an Ingress named `path-ingress` in namespace `multi-path-ns`:
- Path `/v1` → `service-v1:80`
- Path `/v2` → `service-v2:80`
- `pathType: Prefix` for both paths
- `ingressClassName: nginx`

---

## Task 13 (4 pts)
An Ingress named `broken-ingress` already exists in namespace `fix-ingress-ns`.
It is broken — the backend service is set to `wrong-svc` (which does not exist).
**Fix** `broken-ingress` to route traffic to the correct service: `fix-app-svc:80`.

---

## Task 14 (7 pts)
Pre-existing: Deployment `gw-app`, Service `gw-app-svc` (port 80), and GatewayClass `nginx` in namespace `gateway-ns`.

1. Create a **Gateway** named `main-gateway` in namespace `gateway-ns`:
   - `gatewayClassName: nginx`
   - Listener: protocol `HTTP`, port `80`

2. Create an **HTTPRoute** named `app-route` in namespace `gateway-ns`:
   - Parent: `main-gateway`
   - Backend: `gw-app-svc:80`

---

## Task 15 (4 pts)
Pre-existing: Pod `dns-pod` and Service `dns-service` in namespace `dns-test`.

1. Save the FQDN and ClusterIP of `dns-service` to `/var/work/tests/artifacts/15/svc.txt`
   - Format: `<fqdn> <clusterIP>`
   - Expected FQDN: `dns-service.dns-test.svc.cluster.local`

2. Save the FQDN and pod IP of `dns-pod` to `/var/work/tests/artifacts/15/pod.txt`
   - Format: `<fqdn> <podIP>`
   - Pod FQDN format: `<ip-dashes>.<namespace>.pod.cluster.local`

---

## Task 16 (6 pts)
Update the CoreDNS ConfigMap (`coredns` in `kube-system`) to add a stub zone for `custom.local` that forwards to DNS server `8.8.8.8`. Then restart CoreDNS so the change takes effect.

---

## Task 17 (5 pts)
Pre-existing: Namespace `api-access`, ClusterRole `pod-reader` (get/list pods).

1. Create a ServiceAccount named `api-reader-sa` in namespace `api-access`
2. Bind `api-reader-sa` to the ClusterRole `pod-reader`
3. Create a Pod named `api-pod` in namespace `api-access` using image `curlimages/curl:latest` and ServiceAccount `api-reader-sa`
4. From inside `api-pod`, call the Kubernetes API endpoint `/api/v1/pods` using the ServiceAccount token
5. Save the response to `/var/work/tests/artifacts/17/response.txt`

---

## Task 18 (4 pts)
Create an **ExternalName** Service named `external-db` in the `default` namespace that points to `database.example.com`.

---

## Task 19 (4 pts)
In the `default` namespace:
1. Create a Pod named `multi-port-pod` using image `nginx` with ports `80` and `443`
2. Create a Service named `multi-port-svc` exposing:
   - Port `80` named `http`
   - Port `443` named `https`

---

## Task 20 (7 pts)
In namespace `trouble-final`:
- Pod `server-pod` (label `app=server-pod`) and Service `server-svc` already exist
- Pod `client-pod` exists but has label `role=wrong-client`
- NetworkPolicy `allow-client` allows ingress to `server-pod` only from pods with label `role=correct-client`

**Problem:** `client-pod` cannot reach `server-svc` because its label doesn't match the NetworkPolicy.

**Fix** the `client-pod` so it can successfully connect to `server-svc`. Do **not** delete or modify the NetworkPolicy.

---

## Scoring

| Task | Points |
|------|--------|
| 1 | 3 |
| 2 | 5 |
| 3 | 3 |
| 4 | 4 |
| 5 | 6 |
| 6 | 4 |
| 7 | 5 |
| 8 | 6 |
| 9 | 6 |
| 10 | 7 |
| 11 | 4 |
| 12 | 6 |
| 13 | 4 |
| 14 | 7 |
| 15 | 4 |
| 16 | 6 |
| 17 | 5 |
| 18 | 4 |
| 19 | 4 |
| 20 | 7 |
| **Total** | **100** |
