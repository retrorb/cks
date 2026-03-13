# CKA Mock Exam 04 — Cluster Architecture, Installation and Configuration (25%)

**Cluster:** `cluster1-admin@cluster1`
**Time:** 120 minutes
**Total points:** 100

Set the context at the start of each task:
```bash
kubectl config use-context cluster1-admin@cluster1
```

---

## Task 1 (5 pts)
Namespace `rbac-ns` and ServiceAccount `reader-sa` already exist.

Create a **Role** named `pod-reader` in namespace `rbac-ns` that allows `get` and `list` on `pods`.
Create a **RoleBinding** named `pod-reader-binding` in namespace `rbac-ns` that binds the Role to ServiceAccount `reader-sa`.

---

## Task 2 (5 pts)
Namespace `monitoring` and ServiceAccount `node-monitor-sa` already exist.

Create a **ClusterRole** named `node-reader` that allows `get`, `list`, and `watch` on `nodes`.
Create a **ClusterRoleBinding** named `node-reader-binding` that binds the ClusterRole to ServiceAccount `node-monitor-sa` in namespace `monitoring`.

---

## Task 3 (4 pts)
In namespace `fix-rbac`, a RoleBinding named `broken-rb` exists but references the wrong ServiceAccount (`wrong-sa`) instead of the correct one (`fix-sa`).
**Fix** the RoleBinding so it references ServiceAccount `fix-sa`.

---

## Task 4 (4 pts)
Create ServiceAccount `check-sa` in namespace `check-ns`.
Create a ClusterRoleBinding named `check-crb` that binds `check-sa` to the built-in `view` ClusterRole.
Run `kubectl auth can-i list pods --as=system:serviceaccount:check-ns:check-sa` and save the result to `/var/work/tests/artifacts/4/can-i.txt`.

---

## Task 5 (5 pts)
Namespace `deploy-rbac` and ServiceAccount `deploy-sa` already exist.

Create a **Role** named `deploy-manager` in namespace `deploy-rbac` with `create`, `get`, `list`, `update`, `patch`, and `delete` verbs on `deployments`.
Create a **RoleBinding** named `deploy-rb` that binds the Role to ServiceAccount `deploy-sa`.

---

## Task 6 (6 pts)
One of the worker nodes has label `work_type=infra_core`.
**Drain** that node (use `--ignore-daemonsets` and `--delete-emptydir-data`).
After draining, **uncordon** the node so it becomes schedulable again.

---

## Task 7 (4 pts)
Generate a new kubeadm bootstrap token.
Save the token to `/var/work/tests/artifacts/7/token.txt`.

---

## Task 8 (7 pts)
Create an **etcd snapshot** backup to `/var/work/tests/artifacts/8/etcd-backup.db` using `etcdctl`.

The etcd endpoints and certificates are at their default locations:
- Endpoint: `https://127.0.0.1:2379`
- CA: `/etc/kubernetes/pki/etcd/ca.crt`
- Cert: `/etc/kubernetes/pki/etcd/server.crt`
- Key: `/etc/kubernetes/pki/etcd/server.key`

---

## Task 9 (4 pts)
Run `kubeadm certs check-expiration` on the master node and save the output to `/var/work/tests/artifacts/9/certs.txt`.

---

## Task 10 (5 pts)
A local Helm chart named `myapp` is available at `/var/work/helm/myapp/`.
Namespace `helm-ns` already exists.

Install a Helm release named `myapp` from the local chart into namespace `helm-ns`.

---

## Task 11 (4 pts)
A Helm release named `my-release` is already installed in namespace `helm-upgrade-ns`.

**Upgrade** the release to set `replicaCount=3` using `--set replicaCount=3`.

---

## Task 12 (4 pts)
The Helm release `my-release` in namespace `helm-upgrade-ns` was upgraded in the previous task.

**Rollback** the release to revision `1`.

---

## Task 13 (5 pts)
A Kustomize configuration is available at `/var/work/kustomize/task13/`.
It creates a Deployment named `kustomize-app` in namespace `kustomize-ns` using image `nginx:alpine`.

Apply the Kustomize configuration.

---

## Task 14 (5 pts)
A Kustomize **base** configuration is at `/var/work/kustomize/task14/base/`.
It defines a Deployment named `base-deploy` with image `nginx:1.25` in namespace `overlay-ns`.

Create an **overlay** at `/var/work/kustomize/task14/overlay/` that patches the image to `nginx:alpine`.
Apply the overlay.

---

## Task 15 (7 pts)
Create a **CustomResourceDefinition** for `widgets.apps.example.com`:
- Group: `apps.example.com`
- Kind: `Widget`
- Plural: `widgets`
- Scope: `Namespaced`
- Version: `v1`

Namespace `crd-ns` already exists.
Create a **Widget** custom resource named `my-widget` in namespace `crd-ns`.

---

## Task 16 (3 pts)
Identify the CNI plugin installed on the cluster.
Save the plugin name to `/var/work/tests/artifacts/16/cni.txt`.

---

## Task 17 (5 pts)
Namespace `storage-ns` already exists.

Create a **StorageClass** named `local-sc`:
- Provisioner: `kubernetes.io/no-provisioner`
- `volumeBindingMode: WaitForFirstConsumer`

Create a **PersistentVolumeClaim** named `local-pvc` in namespace `storage-ns`:
- StorageClass: `local-sc`
- Access mode: `ReadWriteOnce`
- Size: `1Gi`

---

## Task 18 (4 pts)
Inspect the kube-apiserver static pod manifest at `/etc/kubernetes/manifests/kube-apiserver.yaml`.
Find the value of the `--etcd-servers` flag.
Save the value to `/var/work/tests/artifacts/18/etcd-url.txt`.

---

## Task 19 (6 pts)
Namespace `log-ns` already exists.

1. Create ServiceAccount `log-reader-sa` in namespace `log-ns`
2. Create ClusterRole `log-reader` with `get` and `list` on `pods`, and `get` on `pods/log`
3. Create ClusterRoleBinding `log-reader-crb` binding `log-reader-sa` to `log-reader`
4. Create Pod `log-reader-pod` in namespace `log-ns` using image `bitnami/kubectl:latest` and ServiceAccount `log-reader-sa`, command: `sleep 3600`
5. From inside the pod, run `kubectl get pods -A` and save the output to `/var/work/tests/artifacts/19/pods.txt`

---

## Task 20 (8 pts)
A CRD `backups.storage.example.com` already exists (Kind: `Backup`).
A CR `my-backup` was incorrectly created in the `default` namespace.
Namespace `backup-ns` already exists.

**Recreate** the CR `my-backup` in namespace `backup-ns` (Kind: `Backup`, group `storage.example.com`).

---

## Scoring

| Task | Points |
|------|--------|
| 1 | 5 |
| 2 | 5 |
| 3 | 4 |
| 4 | 4 |
| 5 | 5 |
| 6 | 6 |
| 7 | 4 |
| 8 | 7 |
| 9 | 4 |
| 10 | 5 |
| 11 | 4 |
| 12 | 4 |
| 13 | 5 |
| 14 | 5 |
| 15 | 7 |
| 16 | 3 |
| 17 | 5 |
| 18 | 4 |
| 19 | 6 |
| 20 | 8 |
| **Total** | **100** |
