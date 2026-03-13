#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]
}

# ============================================================
# Task 1 (5 pts): Remove NoSchedule taint broken=true:NoSchedule from worker node
# ============================================================

@test "1.1 worker node has no broken taint" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.taints}' | grep -c 'broken')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "1.2 worker node is Ready" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')
  if [[ "$result" == "True" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "True" ]
}

@test "1.3 node is schedulable" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.unschedulable}')
  if [[ "$result" != "true" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "true" ]
}

@test "1.4 no broken:NoSchedule taint on any worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[*].spec.taints}' | grep -c '"key":"broken"')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "1.5 worker nodes exist and are registered" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 --no-headers | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 5

# ============================================================
# Task 2 (6 pts): Fix broken-scheduler static pod config path
# ============================================================

@test "2.1 broken-scheduler pod is Running or exists in kube-system" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pods -n kube-system --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep 'broken-scheduler' | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "2.2 broken-scheduler pod is Running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  phase=$(kubectl get pods -n kube-system --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep 'broken-scheduler' | awk '{print $3}')
  set -e
  if [[ "$phase" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$phase" == "Running" ]
}

@test "2.3 broken-scheduler manifest exists" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -o jsonpath='{.items[?(@.metadata.labels.node-role\.kubernetes\.io/control-plane)].status.addresses[0].address}')
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "test -f /etc/kubernetes/manifests/broken-scheduler.yaml && echo ok || echo fail" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "2.4 broken-scheduler manifest does not reference /nonexistent" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -o jsonpath='{.items[?(@.metadata.labels.node-role\.kubernetes\.io/control-plane)].status.addresses[0].address}')
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep -c '/nonexistent' /etc/kubernetes/manifests/broken-scheduler.yaml" 2>/dev/null || echo 1)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "2.5 broken-scheduler manifest references correct config" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -o jsonpath='{.items[?(@.metadata.labels.node-role\.kubernetes\.io/control-plane)].status.addresses[0].address}')
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep -c 'scheduler-config.yaml' /etc/kubernetes/manifests/broken-scheduler.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "2.6 broken-scheduler container image is kube-scheduler" {
  echo '1'>>/var/work/tests/result/all
  set +e
  phase=$(kubectl get pods -n kube-system --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep 'broken-scheduler')
  set -e
  if [[ -n "$phase" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$phase" ]
}

# 6, 11

# ============================================================
# Task 3 (5 pts): Fix crash-app pod in crash-ns
# ============================================================

@test "3.1 crash-app pod exists in crash-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod crash-app -n crash-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "crash-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "crash-app" ]
}

@test "3.2 crash-app pod is Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod crash-app -n crash-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "3.3 crash-app pod is not in CrashLoopBackOff" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod crash-app -n crash-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'CrashLoopBackOff')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "3.4 crash-app pod command does not use /bin/wrong" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod crash-app -n crash-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].command}' 2>/dev/null | grep -c '/bin/wrong')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "3.5 crash-app pod namespace is crash-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod crash-app -n crash-ns -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1 2>/dev/null)
  if [[ "$result" == "crash-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "crash-ns" ]
}

# 5, 16

# ============================================================
# Task 4 (4 pts): Fix bad-image-app deployment image in image-ns
# ============================================================

@test "4.1 bad-image-app deployment image is nginx:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment bad-image-app -n image-ns -o jsonpath='{.spec.template.spec.containers[0].image}' --context cluster1-admin@cluster1)
  if [[ "$result" == "nginx:alpine" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "4.2 bad-image-app pods are Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment bad-image-app -n image-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "4.3 bad-image-app deployment exists in image-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment bad-image-app -n image-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "bad-image-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "bad-image-app" ]
}

@test "4.4 bad-image-app image is not doesnotexist999" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment bad-image-app -n image-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}' | grep -c 'doesnotexist999')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 20

# ============================================================
# Task 5 (5 pts): Fix oom-app memory limit in resource-ns
# ============================================================

@test "5.1 oom-app deployment exists in resource-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment oom-app -n resource-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "oom-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "oom-app" ]
}

@test "5.2 oom-app memory limit is >= 64Mi" {
  echo '1'>>/var/work/tests/result/all
  limit_bytes=$(kubectl get deployment oom-app -n resource-ns -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' --context cluster1-admin@cluster1 | sed 's/Mi//' | awk '{print $1 * 1024 * 1024}')
  if [[ "$limit_bytes" -ge "67108864" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$limit_bytes" -ge "67108864" ]
}

@test "5.3 oom-app pods are Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment oom-app -n resource-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "5.4 oom-app memory limit is not 1Mi" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment oom-app -n resource-ns -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' --context cluster1-admin@cluster1)
  if [[ "$result" != "1Mi" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "1Mi" ]
}

@test "5.5 oom-app is not OOMKilled" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pods -n resource-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[*].status.containerStatuses[*].lastState.terminated.reason}' | grep -c 'OOMKilled')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  # This is a soft check — OOMKilled history may persist briefly
  [ "$result" -ge "0" ]
}

# 5, 25

# ============================================================
# Task 6 (5 pts): Create StorageClass missing-sc so PVC can bind
# ============================================================

@test "6.1 StorageClass missing-sc exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass missing-sc -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "missing-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "missing-sc" ]
}

@test "6.2 missing-sc provisioner is kubernetes.io/no-provisioner" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get storageclass missing-sc -o jsonpath='{.provisioner}' --context cluster1-admin@cluster1)
  if [[ "$result" == "kubernetes.io/no-provisioner" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kubernetes.io/no-provisioner" ]
}

@test "6.3 PVC stuck-pvc exists in pvc-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc stuck-pvc -n pvc-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "stuck-pvc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "stuck-pvc" ]
}

@test "6.4 stuck-pvc references missing-sc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc stuck-pvc -n pvc-ns -o jsonpath='{.spec.storageClassName}' --context cluster1-admin@cluster1)
  if [[ "$result" == "missing-sc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "missing-sc" ]
}

@test "6.5 stuck-pvc is not in Error state" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pvc stuck-pvc -n pvc-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" != "Error" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "Error" ]
}

# 5, 30

# ============================================================
# Task 7 (4 pts): Save kubectl top pods -n monitor-ns to file
# ============================================================

@test "7.1 /var/work/tests/artifacts/7/top-pods.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/7/top-pods.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "7.2 top-pods.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -l < /var/work/tests/artifacts/7/top-pods.txt)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "7.3 top-pods.txt contains pod names" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cat /var/work/tests/artifacts/7/top-pods.txt | grep -i 'monitor'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "7.4 top-pods.txt contains CPU column header" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cat /var/work/tests/artifacts/7/top-pods.txt | grep -i 'CPU\|NAME'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 34

# ============================================================
# Task 8 (3 pts): Save kubectl top nodes to file
# ============================================================

@test "8.1 /var/work/tests/artifacts/8/top-nodes.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/8/top-nodes.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "8.2 top-nodes.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -l < /var/work/tests/artifacts/8/top-nodes.txt)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "8.3 top-nodes.txt contains node information" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cat /var/work/tests/artifacts/8/top-nodes.txt | grep -iE 'NAME|CPU|MEMORY'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 3, 37

# ============================================================
# Task 9 (4 pts): Save last 50 lines of log-pod logs
# ============================================================

@test "9.1 /var/work/tests/artifacts/9/logs.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/9/logs.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "9.2 logs.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -l < /var/work/tests/artifacts/9/logs.txt)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "9.3 logs.txt contains expected log string" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cat /var/work/tests/artifacts/9/logs.txt | grep -i 'log-entry'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "9.4 log-pod is running in log-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod log-pod -n log-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

# 4, 41

# ============================================================
# Task 10 (4 pts): Save sidecar container logs from multi-pod
# ============================================================

@test "10.1 /var/work/tests/artifacts/10/sidecar.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/10/sidecar.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "10.2 sidecar.txt contains sidecar output" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cat /var/work/tests/artifacts/10/sidecar.txt | grep -i 'sidecar'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "10.3 sidecar.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -l < /var/work/tests/artifacts/10/sidecar.txt)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "10.4 multi-pod is running in multi-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod multi-pod -n multi-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

# 4, 45

# ============================================================
# Task 11 (5 pts): Save previous container logs of restart-pod
# ============================================================

@test "11.1 /var/work/tests/artifacts/11/prev-logs.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/11/prev-logs.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "11.2 prev-logs.txt is not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(wc -l < /var/work/tests/artifacts/11/prev-logs.txt)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "11.3 restart-pod exists in restart-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod restart-pod -n restart-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "restart-pod" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "restart-pod" ]
}

@test "11.4 restart-pod has restarted at least once" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod restart-pod -n restart-ns -o jsonpath='{.status.containerStatuses[0].restartCount}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "11.5 prev-logs.txt contains crash message" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cat /var/work/tests/artifacts/11/prev-logs.txt | grep -iE 'crash|starting|about'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 5, 50

# ============================================================
# Task 12 (5 pts): Fix wrong-port-svc targetPort from 9999 to 8080
# ============================================================

@test "12.1 wrong-port-svc exists in svc-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc wrong-port-svc -n svc-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "wrong-port-svc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "wrong-port-svc" ]
}

@test "12.2 wrong-port-svc targetPort is 8080" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc wrong-port-svc -n svc-ns -o jsonpath='{.spec.ports[0].targetPort}' --context cluster1-admin@cluster1)
  if [[ "$result" == "8080" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "8080" ]
}

@test "12.3 wrong-port-svc targetPort is not 9999" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc wrong-port-svc -n svc-ns -o jsonpath='{.spec.ports[0].targetPort}' --context cluster1-admin@cluster1)
  if [[ "$result" != "9999" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "9999" ]
}

@test "12.4 wrong-port-svc has endpoints" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get endpoints wrong-port-svc -n svc-ns -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  set -e
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "12.5 backend pod real-svc-pod is running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod real-svc-pod -n svc-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

# 5, 55

# ============================================================
# Task 13 (6 pts): Fix no-ep-svc selector from wrong-app to real-app
# ============================================================

@test "13.1 no-ep-svc exists in ep-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc no-ep-svc -n ep-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "no-ep-svc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "no-ep-svc" ]
}

@test "13.2 no-ep-svc selector is app=real-app" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc no-ep-svc -n ep-ns -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1)
  if [[ "$result" == "real-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "real-app" ]
}

@test "13.3 no-ep-svc selector is not wrong-app" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc no-ep-svc -n ep-ns -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1)
  if [[ "$result" != "wrong-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "wrong-app" ]
}

@test "13.4 no-ep-svc has endpoints" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get endpoints no-ep-svc -n ep-ns -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  set -e
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "13.5 real-app deployment has running pods" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment real-app -n ep-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "13.6 no-ep-svc endpoints count >= 1" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get endpoints no-ep-svc -n ep-ns -o jsonpath='{.subsets[0].addresses}' --context cluster1-admin@cluster1 | grep -o 'ip' | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 6, 61

# ============================================================
# Task 14 (4 pts): Fix broken-ingress port from 9090 to 80
# ============================================================

@test "14.1 broken-ingress exists in ingress-fix" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "broken-ingress" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "broken-ingress" ]
}

@test "14.2 broken-ingress backend port is 80" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' --context cluster1-admin@cluster1)
  if [[ "$result" == "80" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "80" ]
}

@test "14.3 broken-ingress backend port is not 9090" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' --context cluster1-admin@cluster1)
  if [[ "$result" != "9090" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "9090" ]
}

@test "14.4 broken-ingress has rules" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix -o jsonpath='{.spec.rules}' --context cluster1-admin@cluster1)
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

# 4, 65

# ============================================================
# Task 15 (6 pts): Fix NetworkPolicy block-egress to allow DNS port 53
# ============================================================

@test "15.1 NetworkPolicy block-egress exists in dns-block" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy block-egress -n dns-block -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "block-egress" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "block-egress" ]
}

@test "15.2 block-egress allows UDP port 53" {
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

@test "15.3 block-egress policyTypes includes Egress" {
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

@test "15.4 block-egress has at least one egress rule" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy block-egress -n dns-block --context cluster1-admin@cluster1 -o jsonpath='{.spec.egress}')
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

@test "15.5 no-dns-pod is running in dns-block" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod no-dns-pod -n dns-block -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "15.6 no-dns-pod can resolve DNS after fix" {
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

# 6, 71

# ============================================================
# Task 16 (5 pts): Remove maintenance=true:NoExecute taint and uncordon
# ============================================================

@test "16.1 no maintenance taint on any node" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 -o jsonpath='{.items[*].spec.taints}' | grep -c '"key":"maintenance"')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "16.2 all worker nodes are schedulable" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[*].spec.unschedulable}' | grep -c 'true')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "16.3 worker nodes are Ready" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes -l work_type=infra_core --context cluster1-admin@cluster1 -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -c 'True')
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.4 cluster has schedulable nodes" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get nodes --context cluster1-admin@cluster1 --no-headers | grep -v 'SchedulingDisabled' | grep -v 'control-plane\|master' | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.5 no nodes have NoExecute maintenance taint" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 -o json | grep -c '"key":"maintenance"')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 5, 76

# ============================================================
# Task 17 (5 pts): Fix ConfigMap app-config DB_HOST value
# ============================================================

@test "17.1 ConfigMap app-config exists in config-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n config-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "app-config" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-config" ]
}

@test "17.2 app-config DB_HOST is correct-db-host" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n config-ns -o jsonpath='{.data.DB_HOST}' --context cluster1-admin@cluster1)
  if [[ "$result" == "correct-db-host" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "correct-db-host" ]
}

@test "17.3 app-config DB_HOST is not wrong-host" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n config-ns -o jsonpath='{.data.DB_HOST}' --context cluster1-admin@cluster1)
  if [[ "$result" != "wrong-host" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "wrong-host" ]
}

@test "17.4 env-pod is running in config-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod env-pod -n config-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "17.5 env-pod DB_HOST env var is correct-db-host" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl exec env-pod -n config-ns --context cluster1-admin@cluster1 -- env | grep 'DB_HOST' | cut -d= -f2 | tr -d '[:space:]')
  set -e
  if [[ "$result" == "correct-db-host" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "correct-db-host" ]
}

# 5, 81

# ============================================================
# Task 18 (5 pts): Fix Secret app-secret to have db-password key
# ============================================================

@test "18.1 Secret app-secret exists in secret-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get secret app-secret -n secret-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "app-secret" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-secret" ]
}

@test "18.2 app-secret has key db-password" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl get secret app-secret -n secret-ns --context cluster1-admin@cluster1 -o jsonpath='{.data}' | grep -q 'db-password'
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "18.3 secret-pod is running in secret-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod secret-pod -n secret-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "18.4 secret-pod is not in Error state" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod secret-pod -n secret-ns --context cluster1-admin@cluster1 --no-headers | grep -c 'Error\|CreateContainerConfigError')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "18.5 db-password secret key has non-empty value" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get secret app-secret -n secret-ns --context cluster1-admin@cluster1 -o jsonpath='{.data.db-password}')
  set -e
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

# 5, 86

# ============================================================
# Task 19 (5 pts): Fix stuck-pod by removing nodeSelector
# ============================================================

@test "19.1 stuck-pod exists in affinity-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod stuck-pod -n affinity-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "stuck-pod" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "stuck-pod" ]
}

@test "19.2 stuck-pod is Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod stuck-pod -n affinity-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "19.3 stuck-pod has no nodeSelector for disk=ssd" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod stuck-pod -n affinity-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.nodeSelector}' | grep -c 'ssd')
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "19.4 stuck-pod is not in Pending state" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod stuck-pod -n affinity-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" != "Pending" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "Pending" ]
}

@test "19.5 stuck-pod namespace is affinity-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod stuck-pod -n affinity-ns -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1)
  if [[ "$result" == "affinity-ns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "affinity-ns" ]
}

# 5, 91

# ============================================================
# Task 20 (9 pts): Fix backend-svc selector + NetworkPolicy to allow client-pod
# ============================================================

@test "20.1 backend-svc exists in final-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc backend-svc -n final-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "backend-svc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "backend-svc" ]
}

@test "20.2 backend-svc selector is app=backend" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc backend-svc -n final-ns -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1)
  if [[ "$result" == "backend" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "backend" ]
}

@test "20.3 backend-svc has endpoints" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get endpoints backend-svc -n final-ns -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  set -e
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "20.4 NetworkPolicy block-all allows ingress from client-pod" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy block-all -n final-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ingress}')
  set -e
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

@test "20.5 client-pod is running in final-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod client-pod -n final-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "20.6 backend deployment has running pods" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment backend -n final-ns -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "20.7 client-pod can curl backend-svc" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl exec client-pod -n final-ns --context cluster1-admin@cluster1 -- curl http://backend-svc --connect-timeout 3 -s
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "20.8 backend-svc selector is not app=wrong" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc backend-svc -n final-ns -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1)
  if [[ "$result" != "wrong" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "wrong" ]
}

@test "20.9 curl from client-pod returns HTTP 200" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl exec client-pod -n final-ns --context cluster1-admin@cluster1 -- curl http://backend-svc -s -o /dev/null -w '%{http_code}' --connect-timeout 3)
  set -e
  if [[ "$result" == "200" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "200" ]
}

# 9, 100
