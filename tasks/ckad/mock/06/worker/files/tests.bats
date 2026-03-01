#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]

}

# 1 - Helm: Install nginx chart
@test "1.1 Helm release shop-web exists in helm-shop-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-shop-ns --kube-context cluster1-admin@cluster1 -q 2>/dev/null | grep 'shop-web')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "1.2 Helm release shop-web status=deployed" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-shop-ns --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[] | select(.name=="shop-web") | .status')
  if [[ "$result" == "deployed" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "1.3 Helm shop-web pods running in helm-shop-ns. count>=3" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-shop-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'Running')
  if [[ "$result" -ge "3" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "3" ]
}

@test "1.4 Helm shop-web service type=ClusterIP in helm-shop-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc -n helm-shop-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.type}' 2>/dev/null)
  if [[ "$result" == "ClusterIP" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ClusterIP" ]
}
# 4  4

# 2 - Helm: Upgrade release
@test "2.1 Helm release data-api exists in helm-api-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-api-ns --kube-context cluster1-admin@cluster1 -q 2>/dev/null | grep 'data-api')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "2.2 Helm release data-api revision>=2" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-api-ns --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[] | select(.name=="data-api") | .revision')
  if [[ "$result" -ge "2" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "2" ]
}

@test "2.3 Helm data-api pods running in helm-api-ns. count>=4" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-api-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'Running')
  if [[ "$result" -ge "4" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "4" ]
}

@test "2.4 Helm data-api status=deployed" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-api-ns --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[] | select(.name=="data-api") | .status')
  if [[ "$result" == "deployed" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}
# 4  8

# 3 - Helm: Rollback release
@test "3.1 Helm release report-app exists in helm-report-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-report-ns --kube-context cluster1-admin@cluster1 -q 2>/dev/null | grep 'report-app')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "3.2 Helm release report-app status=deployed" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-report-ns --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[] | select(.name=="report-app") | .status')
  if [[ "$result" == "deployed" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "3.3 Helm report-app pods running in helm-report-ns. count>=1" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-report-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'Running')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "3.4 Helm report-app deployment replicas=2 (revision 1 restored)" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment -n helm-report-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null)
  if [[ "$result" == "2" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}
# 4  12

# 4 - Helm: Install with values file
@test "4.1 Helm release metrics-web exists in helm-metrics-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-metrics-ns --kube-context cluster1-admin@cluster1 -q 2>/dev/null | grep 'metrics-web')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "4.2 Helm release metrics-web status=deployed" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-metrics-ns --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[] | select(.name=="metrics-web") | .status')
  if [[ "$result" == "deployed" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "4.3 Helm metrics-web pods running in helm-metrics-ns. count>=2" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-metrics-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'Running')
  if [[ "$result" -ge "2" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "2" ]
}

@test "4.4 Helm metrics-web service type=ClusterIP in helm-metrics-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc -n helm-metrics-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.type}' 2>/dev/null)
  if [[ "$result" == "ClusterIP" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ClusterIP" ]
}
# 4  16

# 5 - Helm: Delete broken release, install fresh
@test "5.1 Helm release broken-release does NOT exist in helm-broken-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-broken-ns --kube-context cluster1-admin@cluster1 -q 2>/dev/null | grep 'broken-release')
  if [[ -z "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -z "$result" ]
}

@test "5.2 Helm release fixed-release exists in helm-broken-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(helm list -n helm-broken-ns --kube-context cluster1-admin@cluster1 -q 2>/dev/null | grep 'fixed-release')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "5.3 Helm fixed-release pods running in helm-broken-ns. count>=1" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-broken-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'Running')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}
# 3  19

# 6 - Kustomize: Image overlay
@test "6.1 Namespace kust2-ns exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace kust2-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "kust2-ns" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kust2-ns" ]
}

@test "6.2 Deployment kust2-app exists in kust2-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment kust2-app -n kust2-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "kust2-app" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kust2-app" ]
}

@test "6.3 Deployment kust2-app image=nginx:1.25" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment kust2-app -n kust2-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
  if [[ "$result" == "nginx:1.25" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:1.25" ]
}

@test "6.4 Deployment kust2-app readyReplicas>=1" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment kust2-app -n kust2-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}
# 4  23

# 7 - Kustomize: ConfigMap generator
@test "7.1 Namespace kgen-ns exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace kgen-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "kgen-ns" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kgen-ns" ]
}

@test "7.2 ConfigMap app-config exists in kgen-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n kgen-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "app-config" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-config" ]
}

@test "7.3 ConfigMap app-config in kgen-ns. APP_MODE=production" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n kgen-ns --context cluster1-admin@cluster1 -o jsonpath='{.data.APP_MODE}' 2>/dev/null)
  if [[ "$result" == "production" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "production" ]
}

@test "7.4 ConfigMap app-config in kgen-ns. LOG_LEVEL=info" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n kgen-ns --context cluster1-admin@cluster1 -o jsonpath='{.data.LOG_LEVEL}' 2>/dev/null)
  if [[ "$result" == "info" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "info" ]
}
# 4  27

# 8 - Kustomize: namePrefix + commonLabels
@test "8.1 Namespace kprod-ns exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace kprod-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "kprod-ns" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kprod-ns" ]
}

@test "8.2 Deployment prod-kust4-app exists in kprod-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment prod-kust4-app -n kprod-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "prod-kust4-app" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "prod-kust4-app" ]
}

@test "8.3 Deployment prod-kust4-app has label env=production" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment prod-kust4-app -n kprod-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.labels.env}' 2>/dev/null)
  if [[ "$result" == "production" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "production" ]
}

@test "8.4 Service prod-kust4-svc exists in kprod-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get service prod-kust4-svc -n kprod-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "prod-kust4-svc" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "prod-kust4-svc" ]
}
# 4  31

# 9 - Kustomize: Strategic merge patch (resource limits)
@test "9.1 Namespace kpatch-ns exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace kpatch-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "kpatch-ns" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kpatch-ns" ]
}

@test "9.2 Deployment cache-app exists in kpatch-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment cache-app -n kpatch-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "cache-app" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "cache-app" ]
}

@test "9.3 Deployment cache-app in kpatch-ns. container cpu limit=200m" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment cache-app -n kpatch-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
  if [[ "$result" == "200m" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "200m" ]
}

@test "9.4 Deployment cache-app in kpatch-ns. container memory limit=256Mi" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment cache-app -n kpatch-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
  if [[ "$result" == "256Mi" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "256Mi" ]
}
# 4  35

# 10 - Blue/Green: Create v2 deployment and switch Ingress
@test "10.1 Deployment v2-deploy exists in bg2-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment v2-deploy -n bg2-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "v2-deploy" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "v2-deploy" ]
}

@test "10.2 Deployment v2-deploy image=viktoruj/ping_pong:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment v2-deploy -n bg2-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
  if [[ "$result" == "viktoruj/ping_pong:alpine" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "viktoruj/ping_pong:alpine" ]
}

@test "10.3 Ingress bg-ingress in bg2-ns backend=v2-svc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress bg-ingress -n bg2-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
  if [[ "$result" == "v2-svc" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "v2-svc" ]
}

@test "10.4 Service v2-svc in bg2-ns has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints v2-svc -n bg2-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  39

# 11 - Canary: Ingress with canary annotations
@test "11.1 Deployment canary-app2 in canary2-ns. image=viktoruj/ping_pong:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment canary-app2 -n canary2-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
  if [[ "$result" == "viktoruj/ping_pong:alpine" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "viktoruj/ping_pong:alpine" ]
}

@test "11.2 Ingress canary-ingress2 in canary2-ns has annotation canary=true" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress canary-ingress2 -n canary2-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/canary}' 2>/dev/null)
  if [[ "$result" == "true" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "true" ]
}

@test "11.3 Ingress canary-ingress2 in canary2-ns. annotation canary-weight=20" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress canary-ingress2 -n canary2-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/canary-weight}' 2>/dev/null)
  if [[ "$result" == "20" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "20" ]
}

@test "11.4 Service canary-svc2 in canary2-ns has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints canary-svc2 -n canary2-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  43

# 12 - Recreate strategy + image update
@test "12.1 Deployment batch-proc in recreate-ns. strategy.type=Recreate" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment batch-proc -n recreate-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.strategy.type}')
  if [[ "$result" == "Recreate" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Recreate" ]
}

@test "12.2 Deployment batch-proc in recreate-ns. image=nginx:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment batch-proc -n recreate-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [[ "$result" == "nginx:alpine" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "12.3 Deployment batch-proc in recreate-ns. readyReplicas>=1" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment batch-proc -n recreate-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.readyReplicas}')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}
# 3  46

# 13 - NetworkPolicy: Default deny all ingress
@test "13.1 NetworkPolicy exists in deny-all-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n deny-all-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "13.2 NetworkPolicy in deny-all-ns applies to all pods (empty podSelector)" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n deny-all-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[] | select(.spec.podSelector == {}) | .metadata.name')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "13.3 tester-pod in ext-ns cannot reach target-pod in deny-all-ns on port 8080" {
  echo '2'>>/var/work/tests/result/all
  set +e
  target_ip=$(kubectl get pod target-pod -n deny-all-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec tester-pod -n ext-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$target_ip:8080" 2>/dev/null
  result=$?
  set -e
  if [[ "$result" != "0" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" != "0" ]
}
# 4  50

# 14 - NetworkPolicy: Allow api->db only
@test "14.1 NetworkPolicy exists in tier-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n tier-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "14.2 api-pod can reach db-pod on port 8080 in tier-ns" {
  echo '1'>>/var/work/tests/result/all
  db_ip=$(kubectl get pod db-pod -n tier-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec api-pod -n tier-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$db_ip:8080" 2>/dev/null
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "14.3 worker-pod cannot reach db-pod on port 8080 in tier-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  db_ip=$(kubectl get pod db-pod -n tier-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec worker-pod -n tier-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$db_ip:8080" 2>/dev/null
  result=$?
  set -e
  if [[ "$result" != "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "0" ]
}

@test "14.4 NetworkPolicy in tier-ns podSelector targets db pods (role=db)" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n tier-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.podSelector.matchLabels.role' | grep 'db')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  54

# 15 - NetworkPolicy: Egress with DNS
@test "15.1 NetworkPolicy exists in egress-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n egress-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "15.2 NetworkPolicy in egress-ns policyTypes includes Egress" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n egress-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.policyTypes[]' | grep 'Egress')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "15.3 NetworkPolicy in egress-ns egress rules include port 443" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n egress-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.egress[].ports[].port] | contains([443])')
  if [[ "$result" == "true" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "true" ]
}

@test "15.4 NetworkPolicy in egress-ns egress rules include port 53" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n egress-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq '[.items[].spec.egress[].ports[].port] | contains([53])')
  if [[ "$result" == "true" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "true" ]
}
# 4  58

# 16 - NetworkPolicy: Cross-namespace (combined selector)
@test "16.1 NetworkPolicy exists in secure-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n secure-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.2 admin-pod in admin-ns can reach vault-app in secure-ns on port 8080" {
  echo '1'>>/var/work/tests/result/all
  vault_ip=$(kubectl get pod -n secure-ns --context cluster1-admin@cluster1 -l app=vault -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
  kubectl exec admin-pod -n admin-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$vault_ip:8080" 2>/dev/null
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "16.3 other-pod in other16-ns cannot reach vault-app in secure-ns on port 8080" {
  echo '1'>>/var/work/tests/result/all
  set +e
  vault_ip=$(kubectl get pod -n secure-ns --context cluster1-admin@cluster1 -l app=vault -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
  kubectl exec other-pod -n other16-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$vault_ip:8080" 2>/dev/null
  result=$?
  set -e
  if [[ "$result" != "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "0" ]
}

@test "16.4 NetworkPolicy in secure-ns uses namespaceSelector" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n secure-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.ingress[].from[] | select(.namespaceSelector != null) | .namespaceSelector' | grep -v 'null')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  62

# 17 - NetworkPolicy: Allow from multiple sources (OR logic)
@test "17.1 NetworkPolicy exists in multi-src-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n multi-src-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "17.2 frontend-pod17 can reach api-pod17 on port 8080 in multi-src-ns" {
  echo '1'>>/var/work/tests/result/all
  api_ip=$(kubectl get pod api-pod17 -n multi-src-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec frontend-pod17 -n multi-src-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$api_ip:8080" 2>/dev/null
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "17.3 monitor-pod17 can reach api-pod17 on port 8080 in multi-src-ns" {
  echo '1'>>/var/work/tests/result/all
  api_ip=$(kubectl get pod api-pod17 -n multi-src-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec monitor-pod17 -n multi-src-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$api_ip:8080" 2>/dev/null
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "17.4 blocked-pod17 cannot reach api-pod17 on port 8080 in multi-src-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  api_ip=$(kubectl get pod api-pod17 -n multi-src-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec blocked-pod17 -n multi-src-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$api_ip:8080" 2>/dev/null
  result=$?
  set -e
  if [[ "$result" != "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "0" ]
}
# 4  66

# 18 - NetworkPolicy: Egress to specific pod
@test "18.1 NetworkPolicy in client-ns policyTypes includes Egress" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n client-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.policyTypes[]' | grep 'Egress')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "18.2 client-pod can reach backend-pod on port 8080 in client-ns" {
  echo '2'>>/var/work/tests/result/all
  backend_ip=$(kubectl get pod backend-pod -n client-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec client-pod -n client-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$backend_ip:8080" 2>/dev/null
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "18.3 client-pod cannot reach external-pod on port 8080 in client-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  external_ip=$(kubectl get pod external-pod -n client-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec client-pod -n client-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$external_ip:8080" 2>/dev/null
  result=$?
  set -e
  if [[ "$result" != "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "0" ]
}
# 4  70

# 19 - NetworkPolicy: Fix broken policy
@test "19.1 NetworkPolicy allow-gateway exists in fix-np-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy allow-gateway -n fix-np-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "allow-gateway" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "allow-gateway" ]
}

@test "19.2 gateway-pod can reach api-service on port 8080 in fix-np-ns" {
  echo '1'>>/var/work/tests/result/all
  api_ip=$(kubectl get pod api-service -n fix-np-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}' 2>/dev/null)
  kubectl exec gateway-pod -n fix-np-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$api_ip:8080" 2>/dev/null
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "19.3 NetworkPolicy allow-gateway from podSelector has role=gateway" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy allow-gateway -n fix-np-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels.role}' 2>/dev/null)
  if [[ "$result" == "gateway" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "gateway" ]
}

@test "19.4 api-service pod in fix-np-ns is Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod api-service -n fix-np-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}' 2>/dev/null)
  if [[ "$result" == "Running" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}
# 4  74

# 20 - Ingress with TLS
@test "20.1 Secret tls-secret in tls-ns exists with type kubernetes.io/tls" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get secret tls-secret -n tls-ns --context cluster1-admin@cluster1 -o jsonpath='{.type}' 2>/dev/null)
  if [[ "$result" == "kubernetes.io/tls" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kubernetes.io/tls" ]
}

@test "20.2 Ingress secure-ingress exists in tls-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress secure-ingress -n tls-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "secure-ingress" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "secure-ingress" ]
}

@test "20.3 Ingress secure-ingress has TLS section with host secure.example.com" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress secure-ingress -n tls-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.tls[0].hosts[0]}' 2>/dev/null)
  if [[ "$result" == "secure.example.com" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "secure.example.com" ]
}

@test "20.4 Ingress secure-ingress backend=secure-svc:80" {
  echo '1'>>/var/work/tests/result/all
  svc=$(kubectl get ingress secure-ingress -n tls-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
  port=$(kubectl get ingress secure-ingress -n tls-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
  if [[ "$svc" == "secure-svc" && "$port" == "80" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$svc" == "secure-svc" ]
  [ "$port" == "80" ]
}
# 4  78

# 21 - Ingress with rewrite-target
@test "21.1 Ingress rewrite-ingress exists in rewrite-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress rewrite-ingress -n rewrite-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "rewrite-ingress" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "rewrite-ingress" ]
}

@test "21.2 Ingress rewrite-ingress has annotation nginx rewrite-target" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress rewrite-ingress -n rewrite-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/rewrite-target}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "21.3 Ingress rewrite-ingress path contains /api" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress rewrite-ingress -n rewrite-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null | grep '/api')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "21.4 Ingress rewrite-ingress backend=api-svc21:8080" {
  echo '1'>>/var/work/tests/result/all
  svc=$(kubectl get ingress rewrite-ingress -n rewrite-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
  port=$(kubectl get ingress rewrite-ingress -n rewrite-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
  if [[ "$svc" == "api-svc21" && "$port" == "8080" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$svc" == "api-svc21" ]
  [ "$port" == "8080" ]
}
# 4  82

# 22 - Ingress with multiple virtual hosts
@test "22.1 Ingress vhost-ingress exists in vhost-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress vhost-ingress -n vhost-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "vhost-ingress" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "vhost-ingress" ]
}

@test "22.2 Ingress vhost-ingress has host rule blog.example.com -> blog-svc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress vhost-ingress -n vhost-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.rules[] | select(.host=="blog.example.com") | .http.paths[0].backend.service.name')
  if [[ "$result" == "blog-svc" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "blog-svc" ]
}

@test "22.3 Ingress vhost-ingress has host rule shop.example.com -> shop-svc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress vhost-ingress -n vhost-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.spec.rules[] | select(.host=="shop.example.com") | .http.paths[0].backend.service.name')
  if [[ "$result" == "shop-svc" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "shop-svc" ]
}

@test "22.4 Service blog-svc in vhost-ns has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints blog-svc -n vhost-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  86

# 23 - Fix wrong ingressClassName
@test "23.1 Ingress web-fix-ingress exists in ingfix-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress web-fix-ingress -n ingfix-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "web-fix-ingress" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "web-fix-ingress" ]
}

@test "23.2 Ingress web-fix-ingress ingressClassName=nginx" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress web-fix-ingress -n ingfix-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)
  if [[ "$result" == "nginx" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx" ]
}

@test "23.3 Ingress web-fix-ingress backend=web-fix-svc:80" {
  echo '1'>>/var/work/tests/result/all
  svc=$(kubectl get ingress web-fix-ingress -n ingfix-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
  port=$(kubectl get ingress web-fix-ingress -n ingfix-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
  if [[ "$svc" == "web-fix-svc" && "$port" == "80" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$svc" == "web-fix-svc" ]
  [ "$port" == "80" ]
}

@test "23.4 Service web-fix-svc in ingfix-ns has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints web-fix-svc -n ingfix-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  90

# 24 - ExternalName Service
@test "24.1 Service db-external exists in extname-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get service db-external -n extname-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "db-external" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "db-external" ]
}

@test "24.2 Service db-external type=ExternalName" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get service db-external -n extname-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.type}' 2>/dev/null)
  if [[ "$result" == "ExternalName" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ExternalName" ]
}

@test "24.3 Service db-external externalName=database.example.internal" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get service db-external -n extname-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.externalName}' 2>/dev/null)
  if [[ "$result" == "database.example.internal" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "database.example.internal" ]
}

@test "24.4 Service db-external port=5432" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get service db-external -n extname-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
  if [[ "$result" == "5432" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "5432" ]
}
# 4  94

# 25 - End-to-end: Service + Ingress + NetworkPolicy
@test "25.1 Service full-svc in e2e-ns type=ClusterIP port=80" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get service full-svc -n e2e-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.type}' 2>/dev/null)
  port=$(kubectl get service full-svc -n e2e-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
  if [[ "$result" == "ClusterIP" && "$port" == "80" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ClusterIP" ]
  [ "$port" == "80" ]
}

@test "25.2 Service full-svc in e2e-ns has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints full-svc -n e2e-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "25.3 Ingress full-ingress in e2e-ns host=full.example.com" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress full-ingress -n e2e-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
  if [[ "$result" == "full.example.com" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "full.example.com" ]
}

@test "25.4 Ingress full-ingress backend=full-svc:80" {
  echo '1'>>/var/work/tests/result/all
  svc=$(kubectl get ingress full-ingress -n e2e-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
  port=$(kubectl get ingress full-ingress -n e2e-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
  if [[ "$svc" == "full-svc" && "$port" == "80" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$svc" == "full-svc" ]
  [ "$port" == "80" ]
}

@test "25.5 NetworkPolicy exists in e2e-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n e2e-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "25.6 NetworkPolicy in e2e-ns restricts ingress to ingress-nginx namespace" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n e2e-ns --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[].spec.ingress[].from[].namespaceSelector.matchLabels | to_entries[] | select(.value=="ingress-nginx") | .value')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 6  100
