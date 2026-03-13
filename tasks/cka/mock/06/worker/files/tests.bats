#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]
}

# ============================================================
# Task 1 (5 pts): Fix cluster2 worker node NotReady — kubelet config path broken
# ============================================================

@test "1.1 cluster2 worker node exists" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster2-admin@cluster2 -l work_type=infra_core --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "1.2 cluster2 worker node is Ready" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes --context cluster2-admin@cluster2 -l work_type=infra_core -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  if [[ "$result" == "True" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "True" ]
}

@test "1.3 cluster2 worker node is schedulable" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes --context cluster2-admin@cluster2 -l work_type=infra_core -o jsonpath='{.items[0].spec.unschedulable}' 2>/dev/null)
  if [[ "$result" != "true" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "true" ]
}

@test "1.4 kubelet is active on cluster2 worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER2=$(kubectl get nodes --context cluster2-admin@cluster2 -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER2} "sudo systemctl is-active kubelet" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "active" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "active" ]
}

@test "1.5 kubelet config path does not reference config-broken.yaml on cluster2 worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER2=$(kubectl get nodes --context cluster2-admin@cluster2 -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER2} "sudo grep -c 'config-broken' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf" 2>/dev/null || echo 1)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 5, 5

# ============================================================
# Task 2 (5 pts): Fix extra-scheduler static pod on cluster2 — wrong config path
# ============================================================

@test "2.1 extra-scheduler pod exists in kube-system on cluster2" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pods -n kube-system --context cluster2-admin@cluster2 --no-headers 2>/dev/null | grep 'extra-scheduler' | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "2.2 extra-scheduler pod is Running on cluster2" {
  echo '1'>>/var/work/tests/result/all
  set +e
  phase=$(kubectl get pods -n kube-system --context cluster2-admin@cluster2 --no-headers 2>/dev/null | grep 'extra-scheduler' | awk '{print $3}')
  set -e
  if [[ "$phase" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$phase" == "Running" ]
}

@test "2.3 extra-scheduler manifest exists on cluster2 master" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER2=$(kubectl get nodes --context cluster2-admin@cluster2 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER2} "test -f /etc/kubernetes/manifests/extra-scheduler.yaml && echo ok || echo fail" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "2.4 extra-scheduler manifest does not reference /nonexistent" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER2=$(kubectl get nodes --context cluster2-admin@cluster2 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER2} "sudo grep -c '/nonexistent' /etc/kubernetes/manifests/extra-scheduler.yaml" 2>/dev/null || echo 1)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "2.5 extra-scheduler manifest references correct scheduler-config.yaml" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER2=$(kubectl get nodes --context cluster2-admin@cluster2 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER2} "sudo grep -c 'scheduler-config.yaml' /etc/kubernetes/manifests/extra-scheduler.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 10

# ============================================================
# Task 3 (6 pts): Backup etcd to /var/work/tests/artifacts/3/etcd-backup.db
# ============================================================

@test "3.1 etcd backup file exists on cluster1 master" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "test -f /var/work/tests/artifacts/3/etcd-backup.db && echo ok || echo fail" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "3.2 etcd backup file is not empty" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "wc -c < /var/work/tests/artifacts/3/etcd-backup.db 2>/dev/null || echo 0" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -gt "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "0" ]
}

@test "3.3 etcd backup file size is > 50000 bytes" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "wc -c < /var/work/tests/artifacts/3/etcd-backup.db 2>/dev/null || echo 0" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -gt "50000" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "50000" ]
}

@test "3.4 etcd pod is still Running on cluster1" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pods -n kube-system --context cluster1-admin@cluster1 -l component=etcd -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
  set -e
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "3.5 etcd backup directory exists on cluster1 master" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "test -d /var/work/tests/artifacts/3 && echo ok || echo fail" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "3.6 etcd backup file is larger than 100000 bytes" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "wc -c < /var/work/tests/artifacts/3/etcd-backup.db 2>/dev/null || echo 0" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -gt "100000" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "100000" ]
}

# 6, 16

# ============================================================
# Task 4 (5 pts): Fix crash-app pod in crash-ns — command /bin/wrong
# ============================================================

@test "4.1 crash-app pod exists in crash-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod crash-app -n crash-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "crash-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "crash-app" ]
}

@test "4.2 crash-app pod is Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod crash-app -n crash-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "4.3 crash-app pod is not in CrashLoopBackOff" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod crash-app -n crash-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'CrashLoopBackOff')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "4.4 crash-app command does not reference /bin/wrong" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod crash-app -n crash-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].command}' 2>/dev/null | grep -c '/bin/wrong')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "4.5 crash-app namespace is crash-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod crash-app -n crash-ns -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "crash-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "crash-ns" ]
}

# 5, 21

# ============================================================
# Task 5 (4 pts): Fix bad-image-app deployment image in image-ns
# ============================================================

@test "5.1 bad-image-app deployment exists in image-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment bad-image-app -n image-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "bad-image-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "bad-image-app" ]
}

@test "5.2 bad-image-app image is nginx:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment bad-image-app -n image-ns -o jsonpath='{.spec.template.spec.containers[0].image}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "nginx:alpine" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "5.3 bad-image-app pods are Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment bad-image-app -n image-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "5.4 bad-image-app image is not doesnotexist999" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment bad-image-app -n image-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}' | grep -c 'doesnotexist999')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 25

# ============================================================
# Task 6 (5 pts): Fix no-ep-svc selector from wrong-app to real-app in ep-ns
# ============================================================

@test "6.1 no-ep-svc exists in ep-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc no-ep-svc -n ep-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "no-ep-svc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "no-ep-svc" ]
}

@test "6.2 no-ep-svc selector is app=real-app" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc no-ep-svc -n ep-ns -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "real-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "real-app" ]
}

@test "6.3 no-ep-svc selector is not wrong-app" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc no-ep-svc -n ep-ns -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" != "wrong-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "wrong-app" ]
}

@test "6.4 no-ep-svc has endpoints" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get endpoints no-ep-svc -n ep-ns -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1 2>/dev/null)
  set -e
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "6.5 real-app deployment has running pods" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment real-app -n ep-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 30

# ============================================================
# Task 7 (5 pts): Fix NetworkPolicy block-egress to allow DNS port 53
# ============================================================

@test "7.1 NetworkPolicy block-egress exists in dns-block" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy block-egress -n dns-block -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "block-egress" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "block-egress" ]
}

@test "7.2 block-egress allows port 53" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl get networkpolicy block-egress -n dns-block --context cluster1-admin@cluster1 -o jsonpath='{.spec.egress[*].ports[*].port}' | grep '53'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "7.3 block-egress policyTypes includes Egress" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl get networkpolicy block-egress -n dns-block --context cluster1-admin@cluster1 -o jsonpath='{.spec.policyTypes}' | grep 'Egress'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "7.4 block-egress has at least one egress rule" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy block-egress -n dns-block --context cluster1-admin@cluster1 -o jsonpath='{.spec.egress}' 2>/dev/null)
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

@test "7.5 no-dns-pod can resolve DNS after fix" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl exec no-dns-pod -n dns-block --context cluster1-admin@cluster1 -- nslookup kubernetes.default.svc.cluster.local > /dev/null 2>&1
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 5, 35

# ============================================================
# Task 8 (4 pts): Fix broken-ingress backend port from 9090 to 80
# ============================================================

@test "8.1 broken-ingress exists in ingress-fix" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "broken-ingress" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "broken-ingress" ]
}

@test "8.2 broken-ingress backend port is 80" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "80" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "80" ]
}

@test "8.3 broken-ingress backend port is not 9090" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" != "9090" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "9090" ]
}

@test "8.4 broken-ingress has rules" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.spec.rules}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

# 4, 39

# ============================================================
# Task 9 (4 pts): Remove broken=true:NoSchedule taint from worker node
# ============================================================

@test "9.1 no broken=true:NoSchedule taint on cluster1 worker nodes" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[*].spec.taints}' | grep -c '"key":"broken"')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "9.2 taint-test deployment exists in default namespace" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment taint-test -n default -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "taint-test" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "taint-test" ]
}

@test "9.3 taint-test deployment has ready replicas" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment taint-test -n default -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "9.4 cluster1 worker nodes are schedulable" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[*].spec.unschedulable}' | grep -c 'true')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 43

# ============================================================
# Task 10 (4 pts): Fix oom-pod memory limit in resource-ns (1Mi -> 64Mi)
# ============================================================

@test "10.1 oom-pod exists in resource-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod oom-pod -n resource-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "oom-pod" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "oom-pod" ]
}

@test "10.2 oom-pod memory limit is not 1Mi" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod oom-pod -n resource-ns -o jsonpath='{.spec.containers[0].resources.limits.memory}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" != "1Mi" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "1Mi" ]
}

@test "10.3 oom-pod is Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod oom-pod -n resource-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "10.4 oom-pod memory limit is >= 64Mi" {
  echo '1'>>/var/work/tests/result/all
  set +e
  raw=$(kubectl get pod oom-pod -n resource-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
  limit_mi=$(echo "$raw" | sed 's/Mi//' | grep -E '^[0-9]+$' || echo 0)
  set -e
  if [[ "$limit_mi" -ge "64" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$limit_mi" -ge "64" ]
}

# 4, 47

# ============================================================
# Task 11 (5 pts): Fix ConfigMap app-config DB_HOST in config-ns
# ============================================================

@test "11.1 ConfigMap app-config exists in config-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n config-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "app-config" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-config" ]
}

@test "11.2 app-config DB_HOST is correct-db-host" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n config-ns -o jsonpath='{.data.DB_HOST}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "correct-db-host" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "correct-db-host" ]
}

@test "11.3 app-config DB_HOST is not wrong-host" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n config-ns -o jsonpath='{.data.DB_HOST}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" != "wrong-host" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "wrong-host" ]
}

@test "11.4 env-pod is running in config-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod env-pod -n config-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "11.5 env-pod DB_HOST env var is correct-db-host" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl exec env-pod -n config-ns --context cluster1-admin@cluster1 -- env 2>/dev/null | grep 'DB_HOST' | cut -d= -f2 | tr -d '[:space:]')
  set -e
  if [[ "$result" == "correct-db-host" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "correct-db-host" ]
}

# 5, 52

# ============================================================
# Task 12 (4 pts): Fix stuck-pod by removing nodeSelector disk=ssd
# ============================================================

@test "12.1 stuck-pod exists in affinity-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod stuck-pod -n affinity-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "stuck-pod" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "stuck-pod" ]
}

@test "12.2 stuck-pod is Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod stuck-pod -n affinity-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "12.3 stuck-pod has no nodeSelector for disk=ssd" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod stuck-pod -n affinity-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.nodeSelector}' 2>/dev/null | grep -c 'ssd')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "12.4 stuck-pod is not in Pending state" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod stuck-pod -n affinity-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" != "Pending" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "Pending" ]
}

# 4, 56

# ============================================================
# Task 13 (5 pts): Create StorageClass fast-sc + PVC fast-pvc + Pod storage-pod
# ============================================================

@test "13.1 StorageClass fast-sc exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass fast-sc -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "fast-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "fast-sc" ]
}

@test "13.2 fast-sc provisioner is kubernetes.io/no-provisioner" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass fast-sc -o jsonpath='{.provisioner}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "kubernetes.io/no-provisioner" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kubernetes.io/no-provisioner" ]
}

@test "13.3 PVC fast-pvc exists in storage-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc fast-pvc -n storage-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "fast-pvc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "fast-pvc" ]
}

@test "13.4 fast-pvc references fast-sc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc fast-pvc -n storage-ns -o jsonpath='{.spec.storageClassName}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "fast-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "fast-sc" ]
}

@test "13.5 Pod storage-pod exists in storage-ns and mounts a volume" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod storage-pod -n storage-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.volumes[0].persistentVolumeClaim.claimName}' 2>/dev/null)
  set -e
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

# 5, 61

# ============================================================
# Task 14 (4 pts): Create StorageClass missing-sc so stuck-pvc can bind
# ============================================================

@test "14.1 StorageClass missing-sc exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass missing-sc -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "missing-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "missing-sc" ]
}

@test "14.2 missing-sc provisioner is kubernetes.io/no-provisioner" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass missing-sc -o jsonpath='{.provisioner}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "kubernetes.io/no-provisioner" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kubernetes.io/no-provisioner" ]
}

@test "14.3 stuck-pvc exists in pvc-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc stuck-pvc -n pvc-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "stuck-pvc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "stuck-pvc" ]
}

@test "14.4 stuck-pvc references missing-sc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc stuck-pvc -n pvc-ns -o jsonpath='{.spec.storageClassName}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "missing-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "missing-sc" ]
}

# 4, 65

# ============================================================
# Task 15 (4 pts): Create PV local-pv (5Gi, hostPath /mnt/data) + PVC local-pvc in pv-ns
# ============================================================

@test "15.1 PV local-pv exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pv local-pv -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "local-pv" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "local-pv" ]
}

@test "15.2 local-pv capacity is 5Gi" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pv local-pv -o jsonpath='{.spec.capacity.storage}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "5Gi" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "5Gi" ]
}

@test "15.3 PVC local-pvc exists in pv-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc local-pvc -n pv-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "local-pvc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "local-pvc" ]
}

@test "15.4 local-pvc is Bound or local-pv is Bound" {
  echo '1'>>/var/work/tests/result/all
  set +e
  pvc_status=$(kubectl get pvc local-pvc -n pv-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  pv_status=$(kubectl get pv local-pv -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  set -e
  if [[ "$pvc_status" == "Bound" ]] || [[ "$pv_status" == "Bound" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$pvc_status" == "Bound" ]] || [[ "$pv_status" == "Bound" ]]
}

# 4, 69

# ============================================================
# Task 16 (4 pts): Change retain-pv reclaimPolicy to Retain + save to file
# ============================================================

@test "16.1 PV retain-pv exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pv retain-pv -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "retain-pv" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "retain-pv" ]
}

@test "16.2 retain-pv reclaimPolicy is Retain" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pv retain-pv -o jsonpath='{.spec.persistentVolumeReclaimPolicy}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "Retain" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Retain" ]
}

@test "16.3 /var/work/tests/artifacts/16/policy.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/16/policy.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "16.4 policy.txt contains Retain" {
  echo '1'>>/var/work/tests/result/all
  set +e
  grep -q 'Retain' /var/work/tests/artifacts/16/policy.txt
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 73

# ============================================================
# Task 17 (6 pts): Rolling update web-app to nginx:alpine, then rollback, save image
# ============================================================

@test "17.1 web-app deployment exists in rollout-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment web-app -n rollout-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "web-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "web-app" ]
}

@test "17.2 web-app has been updated (revision >= 2)" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment web-app -n rollout-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' 2>/dev/null)
  set -e
  if [[ "$result" -ge "2" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "2" ]
}

@test "17.3 web-app current image is nginx:1.25 after rollback" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment web-app -n rollout-ns -o jsonpath='{.spec.template.spec.containers[0].image}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "nginx:1.25" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:1.25" ]
}

@test "17.4 /var/work/tests/artifacts/17/image.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/17/image.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "17.5 image.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -c < /var/work/tests/artifacts/17/image.txt 2>/dev/null || echo 0)
  if [[ "$result" -gt "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "0" ]
}

@test "17.6 image.txt contains nginx:1.25" {
  echo '1'>>/var/work/tests/result/all
  set +e
  grep -q 'nginx:1.25' /var/work/tests/artifacts/17/image.txt
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 6, 79

# ============================================================
# Task 18 (5 pts): Create HPA scalable-app-hpa for scalable-app in hpa-ns
# ============================================================

@test "18.1 HPA scalable-app-hpa exists in hpa-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get hpa scalable-app-hpa -n hpa-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "scalable-app-hpa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "scalable-app-hpa" ]
}

@test "18.2 HPA target is scalable-app deployment" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get hpa scalable-app-hpa -n hpa-ns -o jsonpath='{.spec.scaleTargetRef.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "scalable-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "scalable-app" ]
}

@test "18.3 HPA min replicas is 1" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get hpa scalable-app-hpa -n hpa-ns -o jsonpath='{.spec.minReplicas}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "1" ]
}

@test "18.4 HPA max replicas is 5" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get hpa scalable-app-hpa -n hpa-ns -o jsonpath='{.spec.maxReplicas}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "5" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "5" ]
}

@test "18.5 HPA target CPU utilization is 50" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa scalable-app-hpa -n hpa-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.targetCPUUtilizationPercentage}' 2>/dev/null)
  if [[ -z "$result" ]]; then
    result=$(kubectl get hpa scalable-app-hpa -n hpa-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)
  fi
  set -e
  if [[ "$result" == "50" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "50" ]
}

# 5, 84

# ============================================================
# Task 19 (8 pts): Add nodeAffinity + CPU/memory limits + livenessProbe to affinity-app
# ============================================================

@test "19.1 affinity-app deployment exists in schedule-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment affinity-app -n schedule-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "affinity-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "affinity-app" ]
}

@test "19.2 affinity-app has nodeAffinity preferredDuringScheduling" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment affinity-app -n schedule-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution}' 2>/dev/null)
  set -e
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

@test "19.3 affinity-app nodeAffinity prefers zone=primary" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl get deployment affinity-app -n schedule-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.affinity}' | grep -q 'primary'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "19.4 affinity-app CPU limit is 200m" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment affinity-app -n schedule-ns -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "200m" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "200m" ]
}

@test "19.5 affinity-app memory limit is 256Mi" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment affinity-app -n schedule-ns -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "256Mi" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "256Mi" ]
}

@test "19.6 affinity-app has livenessProbe configured" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment affinity-app -n schedule-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' 2>/dev/null)
  set -e
  if [[ -n "$result" ]] && [[ "$result" != "null" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "null" ]]
}

@test "19.7 affinity-app livenessProbe httpGet path is /healthz" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment affinity-app -n schedule-ns -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "/healthz" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "/healthz" ]
}

@test "19.8 affinity-app livenessProbe periodSeconds is 10" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment affinity-app -n schedule-ns -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.periodSeconds}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "10" ]
}

# 8, 92

# ============================================================
# Task 20 (8 pts): Create ConfigMap app-cm + Secret app-secret + Pod config-pod + save env
# ============================================================

@test "20.1 ConfigMap app-cm exists in config-app-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-cm -n config-app-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "app-cm" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-cm" ]
}

@test "20.2 app-cm has DB_HOST=prod-db" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-cm -n config-app-ns -o jsonpath='{.data.DB_HOST}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "prod-db" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "prod-db" ]
}

@test "20.3 Secret app-secret exists in config-app-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get secret app-secret -n config-app-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "app-secret" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-secret" ]
}

@test "20.4 app-secret has DB_PASS key" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl get secret app-secret -n config-app-ns --context cluster1-admin@cluster1 -o jsonpath='{.data}' 2>/dev/null | grep -q 'DB_PASS'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "20.5 app-secret DB_PASS decodes to s3cr3t" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get secret app-secret -n config-app-ns --context cluster1-admin@cluster1 -o jsonpath='{.data.DB_PASS}' 2>/dev/null | base64 -d 2>/dev/null)
  set -e
  if [[ "$result" == "s3cr3t" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "s3cr3t" ]
}

@test "20.6 config-pod exists in config-app-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod config-pod -n config-app-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "config-pod" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "config-pod" ]
}

@test "20.7 /var/work/tests/artifacts/20/env.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/20/env.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "20.8 env.txt contains DB_HOST=prod-db" {
  echo '1'>>/var/work/tests/result/all
  set +e
  grep -q 'DB_HOST=prod-db' /var/work/tests/artifacts/20/env.txt
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 8, 100
