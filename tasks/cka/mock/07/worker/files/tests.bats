#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]
}

# ============================================================
# Task 1 (4 pts): Helm install analytics chart in helm-install-ns
# ============================================================

@test "1.1 helm release analytics exists in helm-install-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm list -n helm-install-ns --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[].name' | grep -c 'analytics')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "1.2 analytics release status is deployed" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm status analytics -n helm-install-ns --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.info.status')
  set -e
  if [[ "$result" == "deployed" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "1.3 analytics deployment image tag contains v2.1" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deploy analytics -n helm-install-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
  set -e
  if [[ "$result" == *"v2.1"* ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == *"v2.1"* ]]
}

@test "1.4 analytics service port is 9090" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get svc analytics-svc -n helm-install-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
  set -e
  if [[ "$result" == "9090" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "9090" ]
}

# 4, 4

# ============================================================
# Task 2 (3 pts): CNI plugin name and pod CIDR
# ============================================================

@test "2.1 artifact 2/cni-name.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/2/cni-name.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "1" ]
}

@test "2.2 artifact 2/pod-cidr.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/2/pod-cidr.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "1" ]
}

@test "2.3 pod-cidr.txt contains valid CIDR pattern" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -cE '10\.0\.0\.0/16' /var/work/tests/artifacts/2/pod-cidr.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 3, 7

# ============================================================
# Task 3 (5 pts): CRD/CR — explain + create prod-monitor
# ============================================================

@test "3.1 artifact 3/explain.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/3/explain.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "1" ]
}

@test "3.2 CR prod-monitor exists in monitor-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get monitor prod-monitor -n monitor-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "3.3 CR prod-monitor has interval=30s" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get monitor prod-monitor -n monitor-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.interval}' 2>/dev/null)
  set -e
  if [[ "$result" == "30s" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "30s" ]
}

@test "3.4 CR prod-monitor has target=api-server" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get monitor prod-monitor -n monitor-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.target}' 2>/dev/null)
  set -e
  if [[ "$result" == "api-server" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "api-server" ]
}

@test "3.5 explain.txt contains interval or target" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -cE 'interval|target' /var/work/tests/artifacts/3/explain.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 12

# ============================================================
# Task 4 (4 pts): Kubelet inspect — save config, cgroup, containerd
# ============================================================

@test "4.1 artifact 4/kubelet-config.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/4/kubelet-config.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "10" ]
}

@test "4.2 artifact 4/cgroup-driver.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/4/cgroup-driver.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "1" ]
}

@test "4.3 artifact 4/containerd-cgroup.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/4/containerd-cgroup.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "1" ]
}

@test "4.4 cgroup-driver.txt contains systemd" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -ciE 'systemd' /var/work/tests/artifacts/4/cgroup-driver.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 4, 16

# ============================================================
# Task 5 (5 pts): Sidecar — log-aggregator pod
# ============================================================

@test "5.1 pod log-aggregator exists in sidecar-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod log-aggregator -n sidecar-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "5.2 pod log-aggregator is Running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod log-aggregator -n sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}' 2>/dev/null)
  set -e
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "5.3 pod has container app" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod log-aggregator -n sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
  set -e
  if [[ "$result" == *"app"* ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == *"app"* ]]
}

@test "5.4 pod has container log-collector" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod log-aggregator -n sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
  set -e
  if [[ "$result" == *"log-collector"* ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == *"log-collector"* ]]
}

@test "5.5 pod has shared volume log-vol" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod log-aggregator -n sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.volumes[*].name}' 2>/dev/null)
  set -e
  if [[ "$result" == *"log-vol"* ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == *"log-vol"* ]]
}

# 5, 21

# ============================================================
# Task 6 (5 pts): NetworkPolicy deny-all + allow from role=api
# ============================================================

@test "6.1 deny-all NetworkPolicy exists in netpol-deny-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-deny-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[] | select(.spec.ingress==null or .spec.ingress==[]) | select(.spec.policyTypes[]=="Ingress")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.2 allow NetworkPolicy exists in netpol-deny-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-deny-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[] | select(.spec.ingress!=null) | select(.spec.ingress | length > 0)] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.3 allow NP has podSelector role=api" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-deny-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.ingress[]?.from[]?.podSelector?.matchLabels?.role // empty] | map(select(. == "api")) | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.4 allow NP has port 80" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-deny-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.ingress[]?.ports[]?.port // empty] | map(select(. == 80)) | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.5 NP policyTypes includes Ingress" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-deny-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.policyTypes[] | select(. == "Ingress")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 26

# ============================================================
# Task 7 (7 pts): HPA with behavior — worker-hpa
# ============================================================

@test "7.1 HPA worker-hpa exists in hpa-behavior-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa worker-hpa -n hpa-behavior-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "7.2 HPA targets worker-app" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa worker-hpa -n hpa-behavior-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
  set -e
  if [[ "$result" == "worker-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "worker-app" ]
}

@test "7.3 HPA minReplicas=2" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa worker-hpa -n hpa-behavior-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
  set -e
  if [[ "$result" == "2" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}

@test "7.4 HPA maxReplicas=10" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa worker-hpa -n hpa-behavior-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
  set -e
  if [[ "$result" == "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "10" ]
}

@test "7.5 HPA CPU target 60%" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa worker-hpa -n hpa-behavior-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization}' 2>/dev/null)
  set -e
  if [[ "$result" == "60" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "60" ]
}

@test "7.6 HPA scaleDown stabilizationWindowSeconds=300" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa worker-hpa -n hpa-behavior-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.behavior.scaleDown.stabilizationWindowSeconds}' 2>/dev/null)
  set -e
  if [[ "$result" == "300" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "300" ]
}

@test "7.7 HPA scaleUp pods policy exists" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa worker-hpa -n hpa-behavior-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.behavior.scaleUp.policies[]? | select(.type=="Pods") | .value')
  set -e
  if [[ "$result" == "4" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "4" ]
}

# 7, 33

# ============================================================
# Task 8 (5 pts): Fix heavy-pod requests to fit quota
# ============================================================

@test "8.1 pod heavy-pod in quota-ns is Running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod heavy-pod -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}' 2>/dev/null)
  set -e
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "8.2 heavy-pod cpu requests <= 500m" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod heavy-pod -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
  set -e
  if [[ "$result" == "200m" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "200m" ]
}

@test "8.3 heavy-pod memory requests <= 1Gi" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod heavy-pod -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
  set -e
  if [[ "$result" == "256Mi" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "256Mi" ]
}

@test "8.4 ResourceQuota compute-quota still exists" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get resourcequota compute-quota -n quota-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "8.5 heavy-pod has correct reduced limits" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cpu=$(kubectl get pod heavy-pod -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
  mem=$(kubectl get pod heavy-pod -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
  set -e
  if [[ "$cpu" == "200m" ]] && [[ "$mem" == "256Mi" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$cpu" == "200m" ] && [ "$mem" == "256Mi" ]
}

# 5, 38

# ============================================================
# Task 9 (5 pts): Helm template metrics-dash
# ============================================================

@test "9.1 artifact 9/template.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/9/template.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "10" ]
}

@test "9.2 artifact 9/deployed-image.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/9/deployed-image.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "1" ]
}

@test "9.3 deployed-image.txt contains nginx" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -c 'nginx' /var/work/tests/artifacts/9/deployed-image.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "9.4 metrics-dash release exists in helm-tpl-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm list -n helm-tpl-ns --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[].name' | grep -c 'metrics-dash')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "9.5 template.txt contains Deployment" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -c 'Deployment' /var/work/tests/artifacts/9/template.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 43

# ============================================================
# Task 10 (6 pts): Fix extra-apiserver static pod — wrong etcd port
# ============================================================

@test "10.1 extra-apiserver manifest exists on master" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo test -f /etc/kubernetes/manifests/extra-apiserver.yaml && echo exists" 2>/dev/null || echo missing)
  set -e
  if [[ "$result" == "exists" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "exists" ]
}

@test "10.2 extra-apiserver manifest does not contain port 2399" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep -c '2399' /etc/kubernetes/manifests/extra-apiserver.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "10.3 extra-apiserver manifest contains port 2379" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep -c '2379' /etc/kubernetes/manifests/extra-apiserver.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "10.4 crictl.txt artifact exists on master" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "cat /var/work/tests/artifacts/10/crictl.txt 2>/dev/null | wc -c" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -gt "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "10" ]
}

@test "10.5 manifest has correct etcd-servers value" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep -c 'etcd-servers=https://127.0.0.1:2379' /etc/kubernetes/manifests/extra-apiserver.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "10.6 extra-apiserver container running or not CrashLoop" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo crictl ps 2>/dev/null | grep -c extra-apiserver" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 6, 49

# ============================================================
# Task 11 (5 pts): Gateway API — api-gateway + api-route
# ============================================================

@test "11.1 Gateway api-gateway exists in gw-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get gateway api-gateway -n gw-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "11.2 HTTPRoute api-route exists in gw-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute api-route -n gw-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "11.3 HTTPRoute has host api.cluster1.local" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute api-route -n gw-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.hostnames[0]}' 2>/dev/null)
  set -e
  if [[ "$result" == "api.cluster1.local" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "api.cluster1.local" ]
}

@test "11.4 HTTPRoute references api-backend-svc" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute api-route -n gw-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.rules[].backendRefs[]?.name' | grep -c 'api-backend-svc')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "11.5 Gateway listens on port 80" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get gateway api-gateway -n gw-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.listeners[0].port}' 2>/dev/null)
  set -e
  if [[ "$result" == "80" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "80" ]
}

# 5, 54

# ============================================================
# Task 12 (6 pts): NetworkPolicy AND — both podSelector + namespaceSelector
# ============================================================

@test "12.1 NetworkPolicy exists in netpol-and-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-and-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.2 NP targets db-pod role=db" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-and-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.podSelector.matchLabels.role' | grep -c 'db')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.3 NP has podSelector role=api in from" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-and-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.ingress[]?.from[]? | select(.podSelector?.matchLabels?.role == "api")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.4 NP has namespaceSelector env=production in from" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-and-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.ingress[]?.from[]? | select(.namespaceSelector?.matchLabels?.env == "production")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.5 NP policyTypes includes Ingress" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-and-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.policyTypes[] | select(. == "Ingress")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.6 NP single from entry with both selectors (AND logic)" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n netpol-and-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.ingress[]?.from[]? | select(.podSelector?.matchLabels?.role == "api" and .namespaceSelector?.matchLabels?.env == "production")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 6, 60

# ============================================================
# Task 13 (4 pts): Init container — main-deploy with init-wait
# ============================================================

@test "13.1 Deployment main-deploy has init container" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deploy main-deploy -n init-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.initContainers}' 2>/dev/null | jq 'length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "13.2 init container named init-wait" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deploy main-deploy -n init-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null)
  set -e
  if [[ "$result" == *"init-wait"* ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == *"init-wait"* ]]
}

@test "13.3 init container uses nslookup or dig for db-svc" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deploy main-deploy -n init-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.template.spec.initContainers[]? | .command[]?, .args[]?' | grep -cE 'nslookup|dig')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "13.4 main-deploy pods are Running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pods -n init-ns --context cluster1-admin@cluster1 -l app=main-deploy -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
  set -e
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

# 4, 64

# ============================================================
# Task 14 (4 pts): Helm rollback broken-release
# ============================================================

@test "14.1 broken-release revision > 3 (rollback happened)" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm history broken-release -n helm-fix-ns --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq '.[].revision' | sort -n | tail -1)
  set -e
  if [[ "$result" -gt "3" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "3" ]
}

@test "14.2 broken-release pods running (replicas > 0)" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deploy broken-release -n helm-fix-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.replicas}' 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "14.3 artifact 14/history.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/14/history.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "10" ]
}

@test "14.4 history.txt non-empty and contains revision info" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -cE 'revision|REVISION|deployed|superseded' /var/work/tests/artifacts/14/history.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 4, 68

# ============================================================
# Task 15 (5 pts): etcd health + member list
# ============================================================

@test "15.1 artifact 15/health.txt exists on master and non-empty" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "cat /var/work/tests/artifacts/15/health.txt 2>/dev/null | wc -c" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -gt "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "10" ]
}

@test "15.2 artifact 15/members.txt exists on master and non-empty" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "cat /var/work/tests/artifacts/15/members.txt 2>/dev/null | wc -c" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -gt "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "10" ]
}

@test "15.3 health.txt contains healthy" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "grep -c 'healthy' /var/work/tests/artifacts/15/health.txt" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "15.4 members.txt contains content" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "cat /var/work/tests/artifacts/15/members.txt 2>/dev/null | wc -l" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "15.5 etcdctl accessible on master" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "which etcdctl >/dev/null 2>&1 && echo ok" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

# 5, 73

# ============================================================
# Task 16 (5 pts): ResourceQuota + LimitRange in team-ns
# ============================================================

@test "16.1 ResourceQuota team-quota exists in team-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get resourcequota team-quota -n team-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.2 LimitRange team-limits exists in team-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get limitrange team-limits -n team-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.3 quota has pods=10" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get resourcequota team-quota -n team-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.hard.pods}' 2>/dev/null)
  set -e
  if [[ "$result" == "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "10" ]
}

@test "16.4 pod quota-test-pod exists and running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod quota-test-pod -n team-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}' 2>/dev/null)
  set -e
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "16.5 limitrange has default cpu" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get limitrange team-limits -n team-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.limits[]? | select(.type=="Container") | .default.cpu')
  set -e
  if [[ "$result" == "100m" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "100m" ]
}

# 5, 78

# ============================================================
# Task 17 (4 pts): CNI detail — node CIDRs + Calico IPPool
# ============================================================

@test "17.1 artifact 17/node-cidrs.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/17/node-cidrs.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "5" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "5" ]
}

@test "17.2 artifact 17/ippool.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/17/ippool.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "10" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "10" ]
}

@test "17.3 node-cidrs.txt contains CIDR pattern" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -cE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' /var/work/tests/artifacts/17/node-cidrs.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "17.4 ippool.txt contains IPPool" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -c 'IPPool' /var/work/tests/artifacts/17/ippool.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 4, 82

# ============================================================
# Task 18 (6 pts): Fix kubelet cert path on worker
# ============================================================

@test "18.1 worker node is Ready" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  set -e
  if [[ "$result" == "True" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "True" ]
}

@test "18.2 kubelet active on worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo systemctl is-active kubelet" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "active" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "active" ]
}

@test "18.3 kubelet config does not contain wrong" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo grep -c 'wrong' /var/lib/kubelet/config.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "18.4 kubelet config has correct cert path" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo grep -c 'kubelet-client-current.pem\|kubelet.crt' /var/lib/kubelet/config.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "18.5 all worker nodes Ready" {
  echo '1'>>/var/work/tests/result/all
  set +e
  total=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core --no-headers 2>/dev/null | wc -l)
  ready=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core --no-headers 2>/dev/null | grep -c ' Ready')
  set -e
  if [[ "$total" -ge "1" ]] && [[ "$total" == "$ready" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$total" -ge "1" ] && [ "$total" == "$ready" ]
}

@test "18.6 node count >= 2" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "2" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "2" ]
}

# 6, 88

# ============================================================
# Task 19 (6 pts): Sidecar + NetworkPolicy — secure-logger
# ============================================================

@test "19.1 pod secure-logger exists in compound-ns and Running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod secure-logger -n compound-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}' 2>/dev/null)
  set -e
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "19.2 secure-logger has sidecar container" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod secure-logger -n compound-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[*].name}' 2>/dev/null | tr ' ' '\n' | wc -l)
  set -e
  if [[ "$result" -ge "2" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "2" ]
}

@test "19.3 NetworkPolicy exists in compound-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n compound-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "19.4 NP has ingress from role=frontend" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n compound-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.ingress[]?.from[]?.podSelector?.matchLabels?.role // empty] | map(select(. == "frontend")) | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "19.5 NP has egress DNS port 53" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicies -n compound-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.egress[]?.ports[]? | select(.port == 53)] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "19.6 secure-logger has shared volume" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod secure-logger -n compound-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.volumes[*].name}' 2>/dev/null | wc -w)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 6, 94

# ============================================================
# Task 20 (6 pts): Gateway + HPA — gw-backend
# ============================================================

@test "20.1 HPA exists in final-gw-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa -n final-gw-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "20.2 Gateway exists in final-gw-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get gateway -n final-gw-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "20.3 HTTPRoute exists with host app.cluster1.local" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute -n final-gw-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.hostnames[]?' | grep -c 'app.cluster1.local')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "20.4 HPA targets gw-backend" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa -n final-gw-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.scaleTargetRef.name' | grep -c 'gw-backend')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "20.5 artifact 20/status.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(cat /var/work/tests/artifacts/20/status.txt 2>/dev/null | wc -c)
  if [[ "$result" -gt "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -gt "1" ]
}

@test "20.6 HPA min=1 max=8" {
  echo '1'>>/var/work/tests/result/all
  set +e
  min=$(kubectl get hpa -n final-gw-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.minReplicas}' 2>/dev/null)
  max=$(kubectl get hpa -n final-gw-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.maxReplicas}' 2>/dev/null)
  set -e
  if [[ "$min" == "1" ]] && [[ "$max" == "8" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$min" == "1" ] && [ "$max" == "8" ]
}

# 6, 100
