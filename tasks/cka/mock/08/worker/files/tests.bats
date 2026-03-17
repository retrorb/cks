#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]
}

# ============================================================
# Task 1 (4 pts): Helm — add repo, search, install ingress-nginx
# ============================================================

@test "1.1 artifact 1/search.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/1/search.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "1.2 helm release web-ingress exists in helm-repo-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm list -n helm-repo-ns --kubeconfig /home/ubuntu/.kube/_config 2>/dev/null | grep -c 'web-ingress')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "1.3 helm release web-ingress is deployed" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm status web-ingress -n helm-repo-ns --kubeconfig /home/ubuntu/.kube/_config 2>/dev/null | grep -c 'deployed')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "1.4 helm release web-ingress has NodePort" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm get values web-ingress -n helm-repo-ns --all --kubeconfig /home/ubuntu/.kube/_config 2>/dev/null | grep -c 'NodePort')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 4, 4

# ============================================================
# Task 2 (4 pts): CRD/CR — explain alert, create critical-alert
# ============================================================

@test "2.1 artifact 2/spec.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/2/spec.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "2.2 CR critical-alert exists in alert-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get alert critical-alert -n alert-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "2.3 CR critical-alert has severity=critical" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get alert critical-alert -n alert-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.severity}' 2>/dev/null)
  set -e
  if [[ "$result" == "critical" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "critical" ]
}

@test "2.4 CR critical-alert has message field" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get alert critical-alert -n alert-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.message}' 2>/dev/null)
  set -e
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

# 4, 8

# ============================================================
# Task 3 (7 pts): Fix extra-etcd static pod — port mismatch + data-dir
# ============================================================

@test "3.1 extra-etcd manifest exists on master" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "test -f /etc/kubernetes/manifests/extra-etcd.yaml && echo ok || echo fail" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "3.2 extra-etcd manifest does not contain port 2382" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep -c '2382' /etc/kubernetes/manifests/extra-etcd.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "3.3 extra-etcd manifest has listen-peer-urls with 2381" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep 'listen-peer-urls' /etc/kubernetes/manifests/extra-etcd.yaml | grep -c '2381'" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "3.4 extra-etcd manifest has initial-advertise-peer-urls with 2381" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep 'initial-advertise-peer-urls' /etc/kubernetes/manifests/extra-etcd.yaml | grep -c '2381'" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "3.5 extra-etcd manifest does not contain etcd-extra-wrong" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep -c 'etcd-extra-wrong' /etc/kubernetes/manifests/extra-etcd.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "3.6 extra-etcd manifest has correct data-dir /var/lib/etcd-extra" {
  echo '1'>>/var/work/tests/result/all
  set +e
  MASTER=$(kubectl get nodes --context cluster1-admin@cluster1 -l 'node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${MASTER} "sudo grep 'data-dir' /etc/kubernetes/manifests/extra-etcd.yaml | grep -c '/var/lib/etcd-extra'" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "3.7 extra-etcd pod is Running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  phase=$(kubectl get pods -n kube-system --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep 'extra-etcd' | awk '{print $3}')
  set -e
  if [[ "$phase" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$phase" == "Running" ]
}

# 7, 15

# ============================================================
# Task 4 (5 pts): Sidecar adapter pod
# ============================================================

@test "4.1 Pod adapter-pod exists in adapter-ns and Running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  phase=$(kubectl get pod adapter-pod -n adapter-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}' 2>/dev/null)
  set -e
  if [[ "$phase" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$phase" == "Running" ]
}

@test "4.2 adapter-pod has nginx container" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod adapter-pod -n adapter-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[*].image}' 2>/dev/null | grep -c 'nginx')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "4.3 adapter-pod has busybox sidecar" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod adapter-pod -n adapter-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[*].image}' 2>/dev/null | grep -c 'busybox')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "4.4 adapter-pod has volume raw-logs" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod adapter-pod -n adapter-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.volumes[*].name}' 2>/dev/null | grep -c 'raw-logs')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "4.5 adapter-pod has volume adapted-logs" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pod adapter-pod -n adapter-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.volumes[*].name}' 2>/dev/null | grep -c 'adapted-logs')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 20

# ============================================================
# Task 5 (6 pts): HPA advanced — api-hpa with CPU+memory and behavior
# ============================================================

@test "5.1 HPA api-hpa exists in hpa-adv-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa api-hpa -n hpa-adv-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "5.2 HPA api-hpa targets api-service" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa api-hpa -n hpa-adv-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
  set -e
  if [[ "$result" == "api-service" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "api-service" ]
}

@test "5.3 HPA api-hpa minReplicas=3" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa api-hpa -n hpa-adv-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
  set -e
  if [[ "$result" == "3" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}

@test "5.4 HPA api-hpa maxReplicas=15" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa api-hpa -n hpa-adv-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)
  set -e
  if [[ "$result" == "15" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "15" ]
}

@test "5.5 HPA api-hpa has CPU metric" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa api-hpa -n hpa-adv-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '.spec.metrics[] | select(.resource.name=="cpu")' | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "5.6 HPA api-hpa has memory metric" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa api-hpa -n hpa-adv-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '.spec.metrics[] | select(.resource.name=="memory")' | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 6, 26

# ============================================================
# Task 6 (6 pts): NetworkPolicy egress — deny all + allow specific
# ============================================================

@test "6.1 NetworkPolicy exists in egress-ctl-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n egress-ctl-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.2 NetworkPolicy has Egress policyType" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n egress-ctl-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[0].spec.policyTypes[]' | grep -c 'Egress')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.3 NetworkPolicy has egress to port 8080" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n egress-ctl-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.egress[].ports[]? | select(.port==8080)] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.4 NetworkPolicy has DNS port 53" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n egress-ctl-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.egress[].ports[]? | select(.port==53)] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.5 NetworkPolicy has CIDR 10.0.0.0/8" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n egress-ctl-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.egress[]?.to[]? | select(.ipBlock.cidr=="10.0.0.0/8")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "6.6 NetworkPolicy targets egress-pod" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n egress-ctl-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[0].spec.podSelector.matchLabels.app')
  set -e
  if [[ "$result" == "egress-pod" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "egress-pod" ]
}

# 6, 32

# ============================================================
# Task 7 (5 pts): Gateway multi-route — 3 HTTPRoutes
# ============================================================

@test "7.1 HTTPRoute for /users exists in gw-multi-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute -n gw-multi-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[] | select(.spec.rules[]?.matches[]?.path.value=="/users")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "7.2 HTTPRoute for /orders exists in gw-multi-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute -n gw-multi-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[] | select(.spec.rules[]?.matches[]?.path.value=="/orders")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "7.3 HTTPRoute for products.cluster1.local exists in gw-multi-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute -n gw-multi-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[] | select(.spec.hostnames[]?=="products.cluster1.local")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "7.4 HTTPRoutes reference correct backend services" {
  echo '1'>>/var/work/tests/result/all
  set +e
  users=$(kubectl get httproute -n gw-multi-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.rules[].backendRefs[]? | select(.name=="users-svc")] | length')
  orders=$(kubectl get httproute -n gw-multi-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.rules[].backendRefs[]? | select(.name=="orders-svc")] | length')
  products=$(kubectl get httproute -n gw-multi-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.rules[].backendRefs[]? | select(.name=="products-svc")] | length')
  set -e
  if [[ "$users" -ge "1" ]] && [[ "$orders" -ge "1" ]] && [[ "$products" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$users" -ge "1" ]] && [[ "$orders" -ge "1" ]] && [[ "$products" -ge "1" ]]
}

@test "7.5 Gateway shared-gw still exists in gw-multi-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get gateway shared-gw -n gw-multi-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 37

# ============================================================
# Task 8 (4 pts): Scheduling — debug heavy-app, scale down, reduce resources
# ============================================================

@test "8.1 Deployment heavy-app replicas=1" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment heavy-app -n resource-debug-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.replicas}' 2>/dev/null)
  set -e
  if [[ "$result" == "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "1" ]
}

@test "8.2 heavy-app container requests cpu <= 500m" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment heavy-app -n resource-debug-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
  set -e
  if [[ "$result" == "200m" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "200m" ]
}

@test "8.3 artifact 8/events.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/8/events.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "8.4 heavy-app pods are running" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get pods -n resource-debug-ns --context cluster1-admin@cluster1 -l app=heavy-app --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 4, 41

# ============================================================
# Task 9 (6 pts): Fix containerd — disabled CRI plugin on worker
# ============================================================

@test "9.1 all worker nodes are Ready" {
  echo '1'>>/var/work/tests/result/all
  set +e
  not_ready=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core --no-headers 2>/dev/null | grep -cv 'Ready')
  set -e
  if [[ "$not_ready" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$not_ready" == "0" ]
}

@test "9.2 containerd active on first worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo systemctl is-active containerd" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "active" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "active" ]
}

@test "9.3 kubelet active on first worker" {
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

@test "9.4 containerd config has no disabled CRI on first worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo grep -c 'disabled_plugins.*cri' /etc/containerd/config.toml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "9.5 first worker node is Ready" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  set -e
  if [[ "$result" == "True" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "True" ]
}

@test "9.6 first worker node is schedulable" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[0].spec.unschedulable}' 2>/dev/null)
  set -e
  if [[ "$result" != "true" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "true" ]
}

# 6, 47

# ============================================================
# Task 10 (5 pts): CNI fix — expand Calico IPPool
# ============================================================

@test "10.1 Calico IPPool exists" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get ippools --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "10.2 IPPool CIDR covers 10.244.4.0/24" {
  echo '1'>>/var/work/tests/result/all
  set +e
  cidr=$(kubectl get ippools --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.cidr}' 2>/dev/null)
  set -e
  result="fail"
  if [[ "$cidr" == "10.244.0.0/16" ]] || [[ "$cidr" == "10.244.0.0/14" ]] || [[ "$cidr" == "10.244.0.0/12" ]] || [[ "$cidr" == "10.244.0.0/8" ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "10.3 artifact 10 before file exists" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/10/before.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "10.4 artifact 10 after file exists" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/10/after.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "10.5 nodes have podCIDRs assigned" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 -o jsonpath='{.items[*].spec.podCIDR}' 2>/dev/null | wc -w)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 52

# ============================================================
# Task 11 (4 pts): Helm upgrade — install, template, upgrade with prod values
# ============================================================

@test "11.1 helm release webapp-v1 exists in helm-compare-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm list -n helm-compare-ns --kubeconfig /home/ubuntu/.kube/_config 2>/dev/null | grep -c 'webapp-v1')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "11.2 artifact 11/prod-template.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/11/prod-template.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "11.3 helm release webapp-v1 uses httpd image" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm get values webapp-v1 -n helm-compare-ns --all --kubeconfig /home/ubuntu/.kube/_config 2>/dev/null | grep -c 'httpd')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "11.4 helm release webapp-v1 has replicaCount=3" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(helm get values webapp-v1 -n helm-compare-ns --all --kubeconfig /home/ubuntu/.kube/_config 2>/dev/null | grep 'replicaCount' | grep -c '3')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 4, 56

# ============================================================
# Task 12 (7 pts): NetworkPolicy cross-NS AND+OR
# ============================================================

@test "12.1 NetworkPolicy exists in cross-ns-pol" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n cross-ns-pol --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.2 NetworkPolicy targets app=backend" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n cross-ns-pol --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[0].spec.podSelector.matchLabels.app')
  set -e
  if [[ "$result" == "backend" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "backend" ]
}

@test "12.3 NetworkPolicy has podSelector with tier=presentation" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n cross-ns-pol --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.ingress[0].from[] | select(.podSelector.matchLabels.tier=="presentation")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.4 NetworkPolicy has namespaceSelector with purpose=frontend" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n cross-ns-pol --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.ingress[0].from[] | select(.namespaceSelector.matchLabels.purpose=="frontend")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.5 NetworkPolicy has podSelector with app=admin" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n cross-ns-pol --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.ingress[0].from[] | select(.podSelector.matchLabels.app=="admin")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.6 NetworkPolicy has namespaceSelector with purpose=admin" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n cross-ns-pol --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.ingress[0].from[] | select(.namespaceSelector.matchLabels.purpose=="admin")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "12.7 NetworkPolicy has two from entries (AND within, OR between)" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n cross-ns-pol --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '.items[0].spec.ingress[0].from | length')
  set -e
  if [[ "$result" == "2" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}

# 7, 63

# ============================================================
# Task 13 (5 pts): Native sidecar — init container with restartPolicy Always
# ============================================================

@test "13.1 Deployment web-deploy has initContainers" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment web-deploy -n native-sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.initContainers}' 2>/dev/null | jq length)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "13.2 init container named log-shipper" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment web-deploy -n native-sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.initContainers[0].name}' 2>/dev/null)
  set -e
  if [[ "$result" == "log-shipper" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "log-shipper" ]
}

@test "13.3 init container has restartPolicy Always" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment web-deploy -n native-sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.initContainers[0].restartPolicy}' 2>/dev/null)
  set -e
  if [[ "$result" == "Always" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Always" ]
}

@test "13.4 init container image is busybox" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment web-deploy -n native-sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.initContainers[0].image}' 2>/dev/null | grep -c 'busybox')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "13.5 Deployment web-deploy has volume app-logs" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get deployment web-deploy -n native-sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.volumes[*].name}' 2>/dev/null | grep -c 'app-logs')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 68

# ============================================================
# Task 14 (3 pts): Control plane inspect — apiserver flags
# ============================================================

@test "14.1 artifact 14/svc-cidr.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/14/svc-cidr.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "14.2 artifact 14/etcd-url.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/14/etcd-url.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "14.3 artifact 14/auth-mode.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/14/auth-mode.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

# 3, 71

# ============================================================
# Task 15 (3 pts): CNI inspect — node podCIDRs + CNI config
# ============================================================

@test "15.1 artifact 15/node-cidrs.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/15/node-cidrs.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "15.2 artifact 15/cni-conf.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/15/cni-conf.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "15.3 node-cidrs contains CIDR pattern" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -cE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' /var/work/tests/artifacts/15/node-cidrs.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 3, 74

# ============================================================
# Task 16 (5 pts): LimitRange — create strict-limits, test pod, capture error
# ============================================================

@test "16.1 LimitRange strict-limits exists in limit-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get limitrange strict-limits -n limit-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.2 LimitRange has max cpu 500m" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get limitrange strict-limits -n limit-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.limits[0].max.cpu')
  set -e
  if [[ "$result" == "500m" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "500m" ]
}

@test "16.3 LimitRange has min cpu 50m" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get limitrange strict-limits -n limit-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.limits[0].min.cpu')
  set -e
  if [[ "$result" == "50m" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "50m" ]
}

@test "16.4 pod limit-test-pod running in limit-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  phase=$(kubectl get pod limit-test-pod -n limit-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}' 2>/dev/null)
  set -e
  if [[ "$phase" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$phase" == "Running" ]
}

@test "16.5 artifact 16/error.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/16/error.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

# 5, 79

# ============================================================
# Task 17 (3 pts): Kubelet certs — cert expiry + journal
# ============================================================

@test "17.1 artifact 17/cert-expiry.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/17/cert-expiry.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "17.2 artifact 17/kubelet-journal.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/17/kubelet-journal.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "17.3 cert-expiry contains notAfter" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(grep -ci 'notAfter' /var/work/tests/artifacts/17/cert-expiry.txt 2>/dev/null)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 3, 82

# ============================================================
# Task 18 (7 pts): NP+HPA compound — scaled-web with HPA and NetworkPolicy
# ============================================================

@test "18.1 HPA exists in compound-scale-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa -n compound-scale-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "18.2 HPA targets scaled-web" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get hpa -n compound-scale-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.scaleTargetRef.name}' 2>/dev/null)
  set -e
  if [[ "$result" == "scaled-web" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "scaled-web" ]
}

@test "18.3 HPA min=2 max=6" {
  echo '1'>>/var/work/tests/result/all
  set +e
  min=$(kubectl get hpa -n compound-scale-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.minReplicas}' 2>/dev/null)
  max=$(kubectl get hpa -n compound-scale-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.maxReplicas}' 2>/dev/null)
  set -e
  if [[ "$min" == "2" ]] && [[ "$max" == "6" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$min" == "2" ]] && [[ "$max" == "6" ]]
}

@test "18.4 NetworkPolicy exists in compound-scale-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n compound-scale-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "18.5 NetworkPolicy has ingress from role=loadbalancer" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n compound-scale-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.ingress[]?.from[]? | select(.podSelector.matchLabels.role=="loadbalancer")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "18.6 NetworkPolicy has egress port 6379" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n compound-scale-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.egress[].ports[]? | select(.port==6379)] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "18.7 NetworkPolicy has DNS port 53" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get networkpolicy -n compound-scale-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[0].spec.egress[].ports[]? | select(.port==53)] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 7, 89

# ============================================================
# Task 19 (5 pts): Gateway+CNI — secure-gw with TLS + HTTPRoute + CNI config
# ============================================================

@test "19.1 Gateway secure-gw exists in gw-secure-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get gateway secure-gw -n gw-secure-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "19.2 HTTPRoute secure-route exists in gw-secure-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute secure-route -n gw-secure-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "19.3 Gateway secure-gw has HTTPS listener" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get gateway secure-gw -n gw-secure-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.spec.listeners[] | select(.protocol=="HTTPS")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "19.4 HTTPRoute has host secure.cluster1.local" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get httproute secure-route -n gw-secure-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.spec.hostnames[]? | select(.=="secure.cluster1.local")] | length')
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "19.5 artifact 19/cni-conf.txt exists and non-empty" {
  echo '1'>>/var/work/tests/result/all
  result="fail"
  if [[ -s /var/work/tests/artifacts/19/cni-conf.txt ]]; then
    result="ok"
  fi
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

# 5, 94

# ============================================================
# Task 20 (6 pts): Fix kubelet CA path on worker
# ============================================================

@test "20.1 all nodes are Ready" {
  echo '1'>>/var/work/tests/result/all
  set +e
  total=$(kubectl get nodes --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  ready=$(kubectl get nodes --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c ' Ready')
  set -e
  if [[ "$total" -ge "3" ]] && [[ "$total" == "$ready" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$total" -ge "3" ]] && [[ "$total" == "$ready" ]]
}

@test "20.2 kubelet active on second worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[1].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo systemctl is-active kubelet" 2>/dev/null || echo fail)
  set -e
  if [[ "$result" == "active" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "active" ]
}

@test "20.3 kubelet config does not contain ca-wrong on second worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[1].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo grep -c 'ca-wrong' /var/lib/kubelet/config.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "20.4 kubelet config has correct ca.crt on second worker" {
  echo '1'>>/var/work/tests/result/all
  set +e
  WORKER=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[1].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  result=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} "sudo grep -c 'ca\.crt' /var/lib/kubelet/config.yaml" 2>/dev/null || echo 0)
  set -e
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "20.5 second worker node is Ready" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 -l work_type=infra_core -o jsonpath='{.items[1].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
  set -e
  if [[ "$result" == "True" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "True" ]
}

@test "20.6 node count >= 3" {
  echo '1'>>/var/work/tests/result/all
  set +e
  result=$(kubectl get nodes --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l)
  set -e
  if [[ "$result" -ge "3" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "3" ]
}

# 6, 100
