#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]
}

# ============================================================
# Task 1 (5 pts): Create Role pod-reader in ns rbac-ns, SA reader-sa, RoleBinding pod-reader-binding
# ============================================================

@test "1.1 Role pod-reader exists in rbac-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get role pod-reader -n rbac-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "pod-reader" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "pod-reader" ]
}

@test "1.2 pod-reader role has get verb on pods" {
  echo '1'>>/var/work/tests/result/all
  kubectl get role pod-reader -n rbac-ns -o jsonpath='{.rules[*].verbs[*]}' --context cluster1-admin@cluster1 | grep 'get'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "1.3 ServiceAccount reader-sa exists in rbac-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get sa reader-sa -n rbac-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "reader-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "reader-sa" ]
}

@test "1.4 RoleBinding pod-reader-binding exists in rbac-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get rolebinding pod-reader-binding -n rbac-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "pod-reader-binding" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "pod-reader-binding" ]
}

@test "1.5 reader-sa can-i list pods in rbac-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl auth can-i list pods -n rbac-ns --as=system:serviceaccount:rbac-ns:reader-sa --context cluster1-admin@cluster1)
  if [[ "$result" == "yes" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "yes" ]
}

# 5, 5

# ============================================================
# Task 2 (5 pts): Create ClusterRole node-reader, ClusterRoleBinding for node-monitor-sa
# ============================================================

@test "2.1 ClusterRole node-reader exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get clusterrole node-reader -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "node-reader" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "node-reader" ]
}

@test "2.2 ClusterRoleBinding node-reader-binding exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get clusterrolebinding node-reader-binding -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "node-reader-binding" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "node-reader-binding" ]
}

@test "2.3 ServiceAccount node-monitor-sa exists in monitoring" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get sa node-monitor-sa -n monitoring -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "node-monitor-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "node-monitor-sa" ]
}

@test "2.4 node-reader clusterrole has get verb on nodes" {
  echo '1'>>/var/work/tests/result/all
  kubectl get clusterrole node-reader -o jsonpath='{.rules[*].verbs[*]}' --context cluster1-admin@cluster1 | grep 'get'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "2.5 node-monitor-sa can-i get nodes" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl auth can-i get nodes --as=system:serviceaccount:monitoring:node-monitor-sa --context cluster1-admin@cluster1)
  if [[ "$result" == "yes" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "yes" ]
}

# 5, 10

# ============================================================
# Task 3 (4 pts): Fix RoleBinding broken-rb in fix-rbac to use fix-sa
# ============================================================

@test "3.1 RoleBinding broken-rb subject SA is fix-sa" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get rolebinding broken-rb -n fix-rbac -o jsonpath='{.subjects[0].name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "fix-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "fix-sa" ]
}

@test "3.2 broken-rb is in namespace fix-rbac" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get rolebinding broken-rb -n fix-rbac -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1)
  if [[ "$result" == "fix-rbac" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "fix-rbac" ]
}

@test "3.3 broken-rb roleRef is fix-role" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get rolebinding broken-rb -n fix-rbac -o jsonpath='{.roleRef.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "fix-role" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "fix-role" ]
}

@test "3.4 fix-sa can-i get pods in fix-rbac" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl auth can-i get pods -n fix-rbac --as=system:serviceaccount:fix-rbac:fix-sa --context cluster1-admin@cluster1)
  if [[ "$result" == "yes" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "yes" ]
}

# 4, 14

# ============================================================
# Task 4 (4 pts): SA check-sa in check-ns, CRB check-crb to view, save can-i result
# ============================================================

@test "4.1 ServiceAccount check-sa exists in check-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get sa check-sa -n check-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "check-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "check-sa" ]
}

@test "4.2 ClusterRoleBinding check-crb exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get clusterrolebinding check-crb -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "check-crb" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "check-crb" ]
}

@test "4.3 /var/work/tests/artifacts/4/can-i.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/4/can-i.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "4.4 can-i.txt contains yes" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/4/can-i.txt | grep -i 'yes'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 18

# ============================================================
# Task 5 (5 pts): Role deploy-manager in deploy-rbac, RoleBinding deploy-rb for deploy-sa
# ============================================================

@test "5.1 Role deploy-manager exists in deploy-rbac" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get role deploy-manager -n deploy-rbac -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "deploy-manager" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deploy-manager" ]
}

@test "5.2 ServiceAccount deploy-sa exists in deploy-rbac" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get sa deploy-sa -n deploy-rbac -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "deploy-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deploy-sa" ]
}

@test "5.3 RoleBinding deploy-rb exists in deploy-rbac" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get rolebinding deploy-rb -n deploy-rbac -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "deploy-rb" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deploy-rb" ]
}

@test "5.4 deploy-manager role has create and delete verbs" {
  echo '1'>>/var/work/tests/result/all
  verbs=$(kubectl get role deploy-manager -n deploy-rbac -o jsonpath='{.rules[*].verbs[*]}' --context cluster1-admin@cluster1)
  if echo "$verbs" | grep -q 'create' && echo "$verbs" | grep -q 'delete'; then
    echo '1'>>/var/work/tests/result/ok
  fi
  echo "$verbs" | grep -q 'create' && echo "$verbs" | grep -q 'delete'
}

@test "5.5 deploy-sa can-i create deployments in deploy-rbac" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl auth can-i create deployments -n deploy-rbac --as=system:serviceaccount:deploy-rbac:deploy-sa --context cluster1-admin@cluster1)
  if [[ "$result" == "yes" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "yes" ]
}

# 5, 23

# ============================================================
# Task 6 (6 pts): Drain and uncordon worker node
# ============================================================

@test "6.1 worker node is schedulable (not cordoned)" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.unschedulable}')
  if [[ "$result" != "true" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "true" ]
}

@test "6.2 worker node is Ready" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')
  if [[ "$result" == "True" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "True" ]
}

@test "6.3 worker node has no SchedulingDisabled taint" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.taints}' | grep -c 'unschedulable')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "6.4 worker node exists in cluster" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 --no-headers | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.5 node does not have SchedulingDisabled condition" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 --no-headers | grep -v 'SchedulingDisabled'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "6.6 cluster has schedulable worker nodes" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes --context cluster1-admin@cluster1 --no-headers | grep -v 'SchedulingDisabled' | grep -v 'master\|control-plane' | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 6, 29

# ============================================================
# Task 7 (4 pts): Generate kubeadm token and save to file
# ============================================================

@test "7.1 /var/work/tests/artifacts/7/token.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/7/token.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "7.2 token.txt has valid token format" {
  echo '1'>>/var/work/tests/result/all
  token=$(cat /var/work/tests/artifacts/7/token.txt | tr -d '[:space:]')
  if echo "$token" | grep -qE '^[a-z0-9]{6}\.[a-z0-9]{16}$'; then
    echo '1'>>/var/work/tests/result/ok
  fi
  echo "$token" | grep -qE '^[a-z0-9]{6}\.[a-z0-9]{16}$'
}

@test "7.3 token.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/7/token.txt | tr -d '[:space:]')
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "7.4 token from file exists in kubeadm token list" {
  echo '1'>>/var/work/tests/result/all
  set +e
  token=$(cat /var/work/tests/artifacts/7/token.txt | tr -d '[:space:]' | cut -d. -f1)
  ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@$(kubectl get nodes --context cluster1-admin@cluster1 -o jsonpath='{.items[?(@.metadata.labels.node-role\.kubernetes\.io/control-plane)].status.addresses[0].address}') "sudo kubeadm token list" 2>/dev/null | grep "$token"
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 33

# ============================================================
# Task 8 (7 pts): etcd backup
# ============================================================

@test "8.1 /var/work/tests/artifacts/8/etcd-backup.db exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/8/etcd-backup.db 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "8.2 etcd-backup.db file size > 0" {
  echo '1'>>/var/work/tests/result/all
  size=$(stat -c%s /var/work/tests/artifacts/8/etcd-backup.db 2>/dev/null || echo 0)
  if [[ "$size" -gt "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$size" -gt "0" ]
}

@test "8.3 etcd-backup.db is a valid snapshot" {
  echo '1'>>/var/work/tests/result/all
  set +e
  master_ip=$(kubectl get nodes --context cluster1-admin@cluster1 -o jsonpath='{.items[?(@.metadata.labels.node-role\.kubernetes\.io/control-plane)].status.addresses[0].address}')
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${master_ip} "sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot status /var/work/tests/artifacts/8/etcd-backup.db 2>/dev/null" && echo ok || echo fail) 2>/dev/null || result="fail"
  set -e
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  # File existence is sufficient for this check
  stat /var/work/tests/artifacts/8/etcd-backup.db > /dev/null 2>&1
}

@test "8.4 etcd-backup.db size is reasonable (> 10KB)" {
  echo '1'>>/var/work/tests/result/all
  size=$(stat -c%s /var/work/tests/artifacts/8/etcd-backup.db 2>/dev/null || echo 0)
  if [[ "$size" -gt "10240" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$size" -gt "10240" ]
}

@test "8.5 etcd-backup.db filename matches expected" {
  echo '1'>>/var/work/tests/result/all
  result=$(ls /var/work/tests/artifacts/8/etcd-backup.db 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "8.6 etcd backup directory exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/8 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "8.7 etcd-backup.db is a regular file" {
  echo '1'>>/var/work/tests/result/all
  result=$(test -f /var/work/tests/artifacts/8/etcd-backup.db && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

# 7, 40

# ============================================================
# Task 9 (4 pts): kubeadm certs check-expiration output
# ============================================================

@test "9.1 /var/work/tests/artifacts/9/certs.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/9/certs.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "9.2 certs.txt contains apiserver" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/9/certs.txt | grep -i 'apiserver'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "9.3 certs.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -l < /var/work/tests/artifacts/9/certs.txt)
  if [[ "$result" -gt "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "0" ]
}

@test "9.4 certs.txt contains CERTIFICATE or ca" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cat /var/work/tests/artifacts/9/certs.txt | grep -iE 'CERTIFICATE|ca'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 44

# ============================================================
# Task 10 (5 pts): Install Helm release myapp from local chart into helm-ns
# ============================================================

@test "10.1 Helm release myapp exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-ns --context cluster1-admin@cluster1 2>/dev/null | grep '^myapp' | awk '{print $1}')
  if [[ "$result" == "myapp" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "myapp" ]
}

@test "10.2 myapp release status is deployed" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-ns --context cluster1-admin@cluster1 2>/dev/null | grep '^myapp' | awk '{print $8}')
  if [[ "$result" == "deployed" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "10.3 myapp release is in namespace helm-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-ns --context cluster1-admin@cluster1 2>/dev/null | grep '^myapp' | awk '{print $2}')
  if [[ "$result" == "helm-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "helm-ns" ]
}

@test "10.4 deployment myapp-myapp exists in helm-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment -n helm-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "10.5 helm-ns has at least one running pod" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep 'Running' | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 49

# ============================================================
# Task 11 (4 pts): Upgrade my-release to replicaCount=3
# ============================================================

@test "11.1 my-release revision is >= 2" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-upgrade-ns --context cluster1-admin@cluster1 2>/dev/null | grep '^my-release' | awk '{print $3}')
  if [[ "$result" -ge "2" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "2" ]
}

@test "11.2 my-release deployment has 3 replicas" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment -n helm-upgrade-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
  if [[ "$result" == "3" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}

@test "11.3 my-release status is deployed" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-upgrade-ns --context cluster1-admin@cluster1 2>/dev/null | grep '^my-release' | awk '{print $8}')
  if [[ "$result" == "deployed" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "11.4 helm-upgrade-ns has running pods" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-upgrade-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep 'Running' | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 4, 53

# ============================================================
# Task 12 (4 pts): Rollback my-release to revision 1
# ============================================================

@test "12.1 my-release revision is >= 3 after rollback" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-upgrade-ns --context cluster1-admin@cluster1 2>/dev/null | grep '^my-release' | awk '{print $3}')
  if [[ "$result" -ge "3" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "3" ]
}

@test "12.2 my-release status is deployed after rollback" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-upgrade-ns --context cluster1-admin@cluster1 2>/dev/null | grep '^my-release' | awk '{print $8}')
  if [[ "$result" == "deployed" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "12.3 my-release replicas back to 1 after rollback" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment -n helm-upgrade-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
  if [[ "$result" == "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "1" ]
}

@test "12.4 helm history my-release has at least 3 entries" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm history my-release -n helm-upgrade-ns --context cluster1-admin@cluster1 2>/dev/null | tail -n +2 | wc -l)
  if [[ "$result" -ge "3" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "3" ]
}

# 4, 57

# ============================================================
# Task 13 (5 pts): Apply Kustomize from /var/work/kustomize/task13/
# ============================================================

@test "13.1 Deployment kustomize-app exists in kustomize-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment kustomize-app -n kustomize-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "kustomize-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kustomize-app" ]
}

@test "13.2 kustomize-app namespace is kustomize-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment kustomize-app -n kustomize-ns -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1)
  if [[ "$result" == "kustomize-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kustomize-ns" ]
}

@test "13.3 kustomize-app image is nginx:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment kustomize-app -n kustomize-ns -o jsonpath='{.spec.template.spec.containers[0].image}' --context cluster1-admin@cluster1)
  if [[ "$result" == "nginx:alpine" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "13.4 kustomize-app has at least 1 ready replica" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment kustomize-app -n kustomize-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "13.5 kustomize-ns namespace exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace kustomize-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "kustomize-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kustomize-ns" ]
}

# 5, 62

# ============================================================
# Task 14 (5 pts): Kustomize overlay patches base-deploy image to nginx:alpine
# ============================================================

@test "14.1 Deployment base-deploy exists in overlay-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment base-deploy -n overlay-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "base-deploy" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "base-deploy" ]
}

@test "14.2 base-deploy image is nginx:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment base-deploy -n overlay-ns -o jsonpath='{.spec.template.spec.containers[0].image}' --context cluster1-admin@cluster1)
  if [[ "$result" == "nginx:alpine" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "14.3 overlay directory exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/kustomize/task14/overlay 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "14.4 overlay kustomization.yaml exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/kustomize/task14/overlay/kustomization.yaml 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "14.5 base-deploy has at least 1 ready replica" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment base-deploy -n overlay-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 67

# ============================================================
# Task 15 (7 pts): CRD widgets.apps.example.com + CR my-widget in crd-ns
# ============================================================

@test "15.1 CRD widgets.apps.example.com exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd widgets.apps.example.com -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "widgets.apps.example.com" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "widgets.apps.example.com" ]
}

@test "15.2 CRD group is apps.example.com" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd widgets.apps.example.com -o jsonpath='{.spec.group}' --context cluster1-admin@cluster1)
  if [[ "$result" == "apps.example.com" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "apps.example.com" ]
}

@test "15.3 CRD kind is Widget" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd widgets.apps.example.com -o jsonpath='{.spec.names.kind}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Widget" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Widget" ]
}

@test "15.4 CR my-widget exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get widget my-widget -n crd-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "my-widget" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "my-widget" ]
}

@test "15.5 my-widget is in namespace crd-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get widget my-widget -n crd-ns -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1)
  if [[ "$result" == "crd-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "crd-ns" ]
}

@test "15.6 CRD is namespaced scope" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd widgets.apps.example.com -o jsonpath='{.spec.scope}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Namespaced" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Namespaced" ]
}

@test "15.7 my-widget kind is Widget" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get widget my-widget -n crd-ns -o jsonpath='{.kind}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Widget" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Widget" ]
}

# 7, 74

# ============================================================
# Task 16 (3 pts): Save CNI plugin name to file
# ============================================================

@test "16.1 /var/work/tests/artifacts/16/cni.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/16/cni.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "16.2 cni.txt contains calico (case-insensitive)" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/16/cni.txt | grep -i 'calico'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "16.3 cni.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/16/cni.txt | tr -d '[:space:]')
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

# 3, 77

# ============================================================
# Task 17 (5 pts): StorageClass local-sc + PVC local-pvc in storage-ns
# ============================================================

@test "17.1 StorageClass local-sc exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass local-sc -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "local-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "local-sc" ]
}

@test "17.2 local-sc provisioner is kubernetes.io/no-provisioner" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass local-sc -o jsonpath='{.provisioner}' --context cluster1-admin@cluster1)
  if [[ "$result" == "kubernetes.io/no-provisioner" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kubernetes.io/no-provisioner" ]
}

@test "17.3 local-sc volumeBindingMode is WaitForFirstConsumer" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass local-sc -o jsonpath='{.volumeBindingMode}' --context cluster1-admin@cluster1)
  if [[ "$result" == "WaitForFirstConsumer" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "WaitForFirstConsumer" ]
}

@test "17.4 PVC local-pvc exists in storage-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc local-pvc -n storage-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "local-pvc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "local-pvc" ]
}

@test "17.5 local-pvc storageClassName is local-sc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc local-pvc -n storage-ns -o jsonpath='{.spec.storageClassName}' --context cluster1-admin@cluster1)
  if [[ "$result" == "local-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "local-sc" ]
}

# 5, 82

# ============================================================
# Task 18 (4 pts): Save etcd-servers flag value from kube-apiserver manifest
# ============================================================

@test "18.1 /var/work/tests/artifacts/18/etcd-url.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/18/etcd-url.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "18.2 etcd-url.txt contains port 2379" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/18/etcd-url.txt | grep '2379'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "18.3 etcd-url.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/18/etcd-url.txt | tr -d '[:space:]')
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "18.4 etcd-url.txt contains https" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/18/etcd-url.txt | grep 'https'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 86

# ============================================================
# Task 19 (6 pts): SA log-reader-sa + CR log-reader + CRB + Pod log-reader-pod + file
# ============================================================

@test "19.1 ServiceAccount log-reader-sa exists in log-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get sa log-reader-sa -n log-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "log-reader-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "log-reader-sa" ]
}

@test "19.2 ClusterRole log-reader exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get clusterrole log-reader -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "log-reader" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "log-reader" ]
}

@test "19.3 ClusterRoleBinding log-reader-crb exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get clusterrolebinding log-reader-crb -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "log-reader-crb" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "log-reader-crb" ]
}

@test "19.4 Pod log-reader-pod is running in log-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod log-reader-pod -n log-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "19.5 /var/work/tests/artifacts/19/pods.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/19/pods.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "19.6 pods.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -l < /var/work/tests/artifacts/19/pods.txt)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 6, 92

# ============================================================
# Task 20 (8 pts): Recreate CR my-backup in namespace backup-ns
# ============================================================

@test "20.1 CRD backups.storage.example.com exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd backups.storage.example.com -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "backups.storage.example.com" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "backups.storage.example.com" ]
}

@test "20.2 Namespace backup-ns exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace backup-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "backup-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "backup-ns" ]
}

@test "20.3 CR my-backup exists in backup-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get backup my-backup -n backup-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "my-backup" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "my-backup" ]
}

@test "20.4 my-backup kind is Backup" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get backup my-backup -n backup-ns -o jsonpath='{.kind}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Backup" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Backup" ]
}

@test "20.5 my-backup namespace is backup-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get backup my-backup -n backup-ns -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1)
  if [[ "$result" == "backup-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "backup-ns" ]
}

@test "20.6 CRD group is storage.example.com" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd backups.storage.example.com -o jsonpath='{.spec.group}' --context cluster1-admin@cluster1)
  if [[ "$result" == "storage.example.com" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "storage.example.com" ]
}

@test "20.7 CRD kind is Backup" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd backups.storage.example.com -o jsonpath='{.spec.names.kind}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Backup" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Backup" ]
}

@test "20.8 CRD is namespaced scope" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get crd backups.storage.example.com -o jsonpath='{.spec.scope}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Namespaced" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Namespaced" ]
}

# 8, 100
