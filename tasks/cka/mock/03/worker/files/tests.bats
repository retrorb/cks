#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]
}

# ============================================================
# Task 1 (3 pts): Create ClusterIP service backend-service in ns app-1
# ============================================================

@test "1.1 ClusterIP service backend-service exists in app-1" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc backend-service -n app-1 -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "backend-service" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "backend-service" ]
}

@test "1.2 backend-service type is ClusterIP" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc backend-service -n app-1 -o jsonpath='{.spec.type}' --context cluster1-admin@cluster1)
  if [[ "$result" == "ClusterIP" ]] || [[ "$result" == "" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == "ClusterIP" ]] || [[ "$result" == "" ]]
}

@test "1.3 backend-service port 80" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc backend-service -n app-1 -o jsonpath='{.spec.ports[0].port}' --context cluster1-admin@cluster1)
  if [[ "$result" == "80" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "80" ]
}

# 3, 3

# ============================================================
# Task 2 (5 pts): Deployment frontend + NodePort service frontend-service in ns web-app
# ============================================================

@test "2.1 frontend deployment image nginx:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment frontend -n web-app -o jsonpath='{.spec.template.spec.containers[0].image}' --context cluster1-admin@cluster1)
  if [[ "$result" == "nginx:alpine" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "2.2 frontend deployment replicas 2" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment frontend -n web-app -o jsonpath='{.spec.replicas}' --context cluster1-admin@cluster1)
  if [[ "$result" == "2" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}

@test "2.3 frontend-service type NodePort" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc frontend-service -n web-app -o jsonpath='{.spec.type}' --context cluster1-admin@cluster1)
  if [[ "$result" == "NodePort" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "NodePort" ]
}

@test "2.4 frontend-service nodePort 30080" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc frontend-service -n web-app -o jsonpath='{.spec.ports[0].nodePort}' --context cluster1-admin@cluster1)
  if [[ "$result" == "30080" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "30080" ]
}

@test "2.5 frontend deployment pods running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment frontend -n web-app -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

# 5, 8

# ============================================================
# Task 3 (3 pts): Create LoadBalancer service api-lb in default for api-pod port 80->8080
# ============================================================

@test "3.1 LoadBalancer service api-lb exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc api-lb -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "api-lb" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "api-lb" ]
}

@test "3.2 api-lb type is LoadBalancer" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc api-lb -o jsonpath='{.spec.type}' --context cluster1-admin@cluster1)
  if [[ "$result" == "LoadBalancer" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "LoadBalancer" ]
}

@test "3.3 api-lb targetPort 8080" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc api-lb -o jsonpath='{.spec.ports[0].targetPort}' --context cluster1-admin@cluster1)
  if [[ "$result" == "8080" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "8080" ]
}

# 3, 11

# ============================================================
# Task 4 (4 pts): Create Headless service db-headless in ns data for StatefulSet db
# ============================================================

@test "4.1 headless service db-headless exists in data" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc db-headless -n data -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "db-headless" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "db-headless" ]
}

@test "4.2 db-headless clusterIP is None" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc db-headless -n data -o jsonpath='{.spec.clusterIP}' --context cluster1-admin@cluster1)
  if [[ "$result" == "None" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "None" ]
}

@test "4.3 db-headless port 3306" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc db-headless -n data -o jsonpath='{.spec.ports[0].port}' --context cluster1-admin@cluster1)
  if [[ "$result" == "3306" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3306" ]
}

@test "4.4 db-headless selector app=db" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc db-headless -n data -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1)
  if [[ "$result" == "db" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "db" ]
}

# 4, 15

# ============================================================
# Task 5 (6 pts): Fix broken service broken-service in ns fix-me (wrong selector)
# ============================================================

@test "5.1 broken-service exists in fix-me" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc broken-service -n fix-me -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "broken-service" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "broken-service" ]
}

@test "5.2 broken-service selector is app=broken-app" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc broken-service -n fix-me -o jsonpath='{.spec.selector.app}' --context cluster1-admin@cluster1)
  if [[ "$result" == "broken-app" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "broken-app" ]
}

@test "5.3 broken-app deployment pods running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment broken-app -n fix-me -o jsonpath='{.status.readyReplicas}' --context cluster1-admin@cluster1)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "5.4 broken-service has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints broken-service -n fix-me -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "5.5 broken-service endpoint IP matches pod IP" {
  echo '1'>>/var/work/tests/result/all
  endpoint_ip=$(kubectl get endpoints broken-service -n fix-me -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  pod_ip=$(kubectl get pods -n fix-me -l app=broken-app -o jsonpath='{.items[0].status.podIP}' --context cluster1-admin@cluster1)
  if [[ "$endpoint_ip" == "$pod_ip" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$endpoint_ip" == "$pod_ip" ]
}

@test "5.6 broken-service endpoints not empty" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints broken-service -n fix-me --context cluster1-admin@cluster1 -o jsonpath='{.subsets}')
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

# 6, 21

# ============================================================
# Task 6 (4 pts): Create pod endpoint-test + service endpoint-service, save endpoint IP
# ============================================================

@test "6.1 pod endpoint-test running in default" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod endpoint-test -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "6.2 service endpoint-service exists in default" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc endpoint-service -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "endpoint-service" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "endpoint-service" ]
}

@test "6.3 endpoint-service has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints endpoint-service -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "6.4 /var/work/tests/artifacts/6/endpoints.txt contains endpoint IP" {
  echo '1'>>/var/work/tests/result/all
  set +e
  pod_ip=$(kubectl get endpoints endpoint-service -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  cat /var/work/tests/artifacts/6/endpoints.txt | grep "$pod_ip"
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 25

# ============================================================
# Task 7 (5 pts): Deny-all ingress NetworkPolicy in ns policy-ns
# ============================================================

@test "7.1 deny-all NetworkPolicy exists in policy-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy deny-all -n policy-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "deny-all" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deny-all" ]
}

@test "7.2 deny-all has empty podSelector" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy deny-all -n policy-ns -o jsonpath='{.spec.podSelector}' --context cluster1-admin@cluster1)
  if [[ "$result" == "{}" ]] || [[ "$result" == "" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == "{}" ]] || [[ "$result" == "" ]]
}

@test "7.3 deny-all has empty ingress rules" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy deny-all -n policy-ns -o jsonpath='{.spec.ingress}' --context cluster1-admin@cluster1)
  if [[ "$result" == "" ]] || [[ "$result" == "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ "$result" == "" ]] || [[ "$result" == "[]" ]]
}

@test "7.4 deny-all policyTypes includes Ingress" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy deny-all -n policy-ns -o jsonpath='{.spec.policyTypes}' --context cluster1-admin@cluster1 | grep 'Ingress'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "7.5 external-client cannot reach target-app in policy-ns" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl exec external-client -n external-ns --context cluster1-admin@cluster1 -- curl http://target-app.policy-ns.svc --connect-timeout 2 -s
  result=$?
  set -e
  if (( $result > 0 )); then
    echo '1'>>/var/work/tests/result/ok
  fi
  (( $result > 0 ))
}

# 5, 30

# ============================================================
# Task 8 (6 pts): Allow specific pod NetworkPolicy in ns app-net
# ============================================================

@test "8.1 allow-client-to-server NetworkPolicy exists in app-net" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy allow-client-to-server -n app-net -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "allow-client-to-server" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "allow-client-to-server" ]
}

@test "8.2 allow-client-to-server podSelector targets app=server" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy allow-client-to-server -n app-net -o jsonpath='{.spec.podSelector.matchLabels.app}' --context cluster1-admin@cluster1)
  if [[ "$result" == "server" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "server" ]
}

@test "8.3 allow-client-to-server ingress from role=client" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy allow-client-to-server -n app-net -o jsonpath='{.spec.ingress[0].from[0].podSelector.matchLabels}' --context cluster1-admin@cluster1 | grep 'client'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "8.4 allowed-client can connect to server" {
  echo '1'>>/var/work/tests/result/all
  kubectl exec allowed-client -n allowed-net --context cluster1-admin@cluster1 -- curl http://server.app-net.svc --connect-timeout 3 -s
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "8.5 denied-client cannot connect to server" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl exec denied-client -n allowed-net --context cluster1-admin@cluster1 -- curl http://server.app-net.svc --connect-timeout 2 -s
  result=$?
  set -e
  if (( $result > 0 )); then
    echo '1'>>/var/work/tests/result/ok
  fi
  (( $result > 0 ))
}

@test "8.6 server pod running in app-net" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod server -n app-net -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

# 6, 36

# ============================================================
# Task 9 (6 pts): Cross-namespace NetworkPolicy in ns secure-ns
# ============================================================

@test "9.1 allow-trusted-namespace NetworkPolicy exists in secure-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy allow-trusted-namespace -n secure-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "allow-trusted-namespace" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "allow-trusted-namespace" ]
}

@test "9.2 allow-trusted-namespace uses namespaceSelector" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy allow-trusted-namespace -n secure-ns -o jsonpath='{.spec.ingress[0].from[0].namespaceSelector}' --context cluster1-admin@cluster1 | grep 'trusted'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "9.3 allow-trusted-namespace policyTypes is Ingress" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy allow-trusted-namespace -n secure-ns -o jsonpath='{.spec.policyTypes}' --context cluster1-admin@cluster1 | grep 'Ingress'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "9.4 trusted-client can connect to secure-server" {
  echo '1'>>/var/work/tests/result/all
  kubectl exec trusted-client -n trusted-ns --context cluster1-admin@cluster1 -- curl http://secure-server.secure-ns.svc --connect-timeout 3 -s
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "9.5 untrusted-client cannot connect to secure-server" {
  echo '1'>>/var/work/tests/result/all
  set +e
  kubectl exec untrusted-client -n untrusted-ns --context cluster1-admin@cluster1 -- curl http://secure-server.secure-ns.svc --connect-timeout 2 -s
  result=$?
  set -e
  if (( $result > 0 )); then
    echo '1'>>/var/work/tests/result/ok
  fi
  (( $result > 0 ))
}

@test "9.6 secure-server pod running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod secure-server -n secure-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

# 6, 42

# ============================================================
# Task 10 (7 pts): Egress NetworkPolicy in ns restricted-ns
# ============================================================

@test "10.1 restrict-egress NetworkPolicy exists in restricted-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy restrict-egress -n restricted-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "restrict-egress" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "restrict-egress" ]
}

@test "10.2 restrict-egress policyTypes includes Ingress" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy restrict-egress -n restricted-ns -o jsonpath='{.spec.policyTypes}' --context cluster1-admin@cluster1 | grep 'Ingress'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "10.3 restrict-egress policyTypes includes Egress" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy restrict-egress -n restricted-ns -o jsonpath='{.spec.policyTypes}' --context cluster1-admin@cluster1 | grep 'Egress'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "10.4 restrict-egress allows DNS port 53" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy restrict-egress -n restricted-ns -o jsonpath='{.spec.egress[*].ports[*].port}' --context cluster1-admin@cluster1 | grep '53'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "10.5 restrict-egress allows port 80" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy restrict-egress -n restricted-ns -o jsonpath='{.spec.egress[*].ports[*].port}' --context cluster1-admin@cluster1 | grep '80'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "10.6 restrict-egress has namespaceSelector in egress" {
  echo '1'>>/var/work/tests/result/all
  kubectl get networkpolicy restrict-egress -n restricted-ns -o jsonpath='{.spec.egress[*].to[*].namespaceSelector}' --context cluster1-admin@cluster1 | grep -v '^$'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "10.7 restricted-pod is running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod restricted-pod -n restricted-ns -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

# 7, 49

# ============================================================
# Task 11 (4 pts): Create Ingress main-ingress in ns ingress-ns
# ============================================================

@test "11.1 main-ingress exists in ingress-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress main-ingress -n ingress-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "main-ingress" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "main-ingress" ]
}

@test "11.2 main-ingress host is app.k8s.local" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress main-ingress -n ingress-ns -o jsonpath='{.spec.rules[0].host}' --context cluster1-admin@cluster1)
  if [[ "$result" == "app.k8s.local" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app.k8s.local" ]
}

@test "11.3 main-ingress path is /" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress main-ingress -n ingress-ns -o jsonpath='{.spec.rules[0].http.paths[0].path}' --context cluster1-admin@cluster1)
  if [[ "$result" == "/" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "/" ]
}

@test "11.4 main-ingress backend service is ingress-app-svc" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress main-ingress -n ingress-ns -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "ingress-app-svc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ingress-app-svc" ]
}

# 4, 53

# ============================================================
# Task 12 (6 pts): Create Ingress path-ingress in ns multi-path-ns
# ============================================================

@test "12.1 path-ingress exists in multi-path-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress path-ingress -n multi-path-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "path-ingress" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "path-ingress" ]
}

@test "12.2 path-ingress has /v1 path" {
  echo '1'>>/var/work/tests/result/all
  kubectl get ingress path-ingress -n multi-path-ns -o jsonpath='{.spec.rules[0].http.paths[*].path}' --context cluster1-admin@cluster1 | grep '/v1'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "12.3 path-ingress has /v2 path" {
  echo '1'>>/var/work/tests/result/all
  kubectl get ingress path-ingress -n multi-path-ns -o jsonpath='{.spec.rules[0].http.paths[*].path}' --context cluster1-admin@cluster1 | grep '/v2'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "12.4 path-ingress /v1 backend is service-v1" {
  echo '1'>>/var/work/tests/result/all
  kubectl get ingress path-ingress -n multi-path-ns -o jsonpath='{.spec.rules[0].http.paths[*].backend.service.name}' --context cluster1-admin@cluster1 | grep 'service-v1'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "12.5 path-ingress /v2 backend is service-v2" {
  echo '1'>>/var/work/tests/result/all
  kubectl get ingress path-ingress -n multi-path-ns -o jsonpath='{.spec.rules[0].http.paths[*].backend.service.name}' --context cluster1-admin@cluster1 | grep 'service-v2'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "12.6 path-ingress pathType is Prefix" {
  echo '1'>>/var/work/tests/result/all
  kubectl get ingress path-ingress -n multi-path-ns -o jsonpath='{.spec.rules[0].http.paths[*].pathType}' --context cluster1-admin@cluster1 | grep 'Prefix'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 6, 59

# ============================================================
# Task 13 (4 pts): Fix Ingress broken-ingress in ns fix-ingress-ns
# ============================================================

@test "13.1 broken-ingress backend service is fix-app-svc" {
  echo '1'>>/var/work/tests/result/all
  kubectl get ingress broken-ingress -n fix-ingress-ns -o jsonpath='{.spec.rules[0].http.paths[*].backend.service.name}' --context cluster1-admin@cluster1 | grep 'fix-app-svc'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "13.2 broken-ingress backend port 80" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n fix-ingress-ns -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' --context cluster1-admin@cluster1)
  if [[ "$result" == "80" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "80" ]
}

@test "13.3 broken-ingress ingressClassName nginx" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n fix-ingress-ns -o jsonpath='{.spec.ingressClassName}' --context cluster1-admin@cluster1)
  if [[ "$result" == "nginx" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx" ]
}

@test "13.4 broken-ingress has at least one rule" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n fix-ingress-ns -o jsonpath='{.spec.rules}' --context cluster1-admin@cluster1)
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

# 4, 63

# ============================================================
# Task 14 (7 pts): Create Gateway main-gateway + HTTPRoute app-route in ns gateway-ns
# ============================================================

@test "14.1 Gateway main-gateway exists in gateway-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get gateway main-gateway -n gateway-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "main-gateway" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "main-gateway" ]
}

@test "14.2 main-gateway listener port 80" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get gateway main-gateway -n gateway-ns -o jsonpath='{.spec.listeners[0].port}' --context cluster1-admin@cluster1)
  if [[ "$result" == "80" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "80" ]
}

@test "14.3 main-gateway gatewayClassName nginx" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get gateway main-gateway -n gateway-ns -o jsonpath='{.spec.gatewayClassName}' --context cluster1-admin@cluster1)
  if [[ "$result" == "nginx" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx" ]
}

@test "14.4 HTTPRoute app-route exists in gateway-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get httproute app-route -n gateway-ns -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "app-route" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-route" ]
}

@test "14.5 app-route parentRef points to main-gateway" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get httproute app-route -n gateway-ns -o jsonpath='{.spec.parentRefs[0].name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "main-gateway" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "main-gateway" ]
}

@test "14.6 app-route backendRef service is gw-app-svc" {
  echo '1'>>/var/work/tests/result/all
  kubectl get httproute app-route -n gateway-ns -o jsonpath='{.spec.rules[0].backendRefs[*].name}' --context cluster1-admin@cluster1 | grep 'gw-app-svc'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "14.7 main-gateway has at least one listener" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get gateway main-gateway -n gateway-ns -o jsonpath='{.spec.listeners}' --context cluster1-admin@cluster1)
  if [[ -n "$result" ]] && [[ "$result" != "[]" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [[ -n "$result" ]] && [[ "$result" != "[]" ]]
}

# 7, 70

# ============================================================
# Task 15 (4 pts): Save DNS FQDN of service and pod in ns dns-test
# ============================================================

@test "15.1 /var/work/tests/artifacts/15/svc.txt contains service FQDN" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/15/svc.txt | grep 'dns-service.dns-test.svc.cluster.local'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "15.2 /var/work/tests/artifacts/15/pod.txt contains pod DNS suffix" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/15/pod.txt | grep 'dns-test.pod.cluster.local'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "15.3 svc.txt contains service cluster IP" {
  echo '1'>>/var/work/tests/result/all
  set +e
  svc_ip=$(kubectl get svc dns-service -n dns-test -o jsonpath='{.spec.clusterIP}' --context cluster1-admin@cluster1)
  cat /var/work/tests/artifacts/15/svc.txt | grep "$svc_ip"
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "15.4 pod.txt contains pod IP in dashed format" {
  echo '1'>>/var/work/tests/result/all
  set +e
  pod_ip=$(kubectl get pod dns-pod -n dns-test -o jsonpath='{.status.podIP}' --context cluster1-admin@cluster1)
  pod_ip_dashed=$(echo "$pod_ip" | sed 's/\./-/g')
  cat /var/work/tests/artifacts/15/pod.txt | grep "$pod_ip_dashed"
  result=$?
  set -e
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 4, 74

# ============================================================
# Task 16 (6 pts): Update CoreDNS ConfigMap with custom.local stub zone
# ============================================================

@test "16.1 CoreDNS ConfigMap exists in kube-system" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap coredns -n kube-system -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "coredns" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "coredns" ]
}

@test "16.2 CoreDNS Corefile has custom.local zone" {
  echo '1'>>/var/work/tests/result/all
  kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}' --context cluster1-admin@cluster1 | grep 'custom.local'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "16.3 CoreDNS Corefile forwards custom.local to 8.8.8.8" {
  echo '1'>>/var/work/tests/result/all
  kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}' --context cluster1-admin@cluster1 | grep '8.8.8.8'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "16.4 CoreDNS pods are running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n kube-system -l k8s-app=kube-dns --context cluster1-admin@cluster1 --no-headers | grep 'Running' | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.5 CoreDNS pods are Ready" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pods -n kube-system -l k8s-app=kube-dns --context cluster1-admin@cluster1 -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep 'True' | wc -l)
  if [[ "$result" -ge "1" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.6 CoreDNS Corefile has forward directive for custom.local" {
  echo '1'>>/var/work/tests/result/all
  kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}' --context cluster1-admin@cluster1 | grep -A5 'custom.local' | grep 'forward'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 6, 80

# ============================================================
# Task 17 (5 pts): SA + ClusterRoleBinding + pod accessing /api/v1/pods
# ============================================================

@test "17.1 ServiceAccount api-reader-sa exists in api-access" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get sa api-reader-sa -n api-access -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "api-reader-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "api-reader-sa" ]
}

@test "17.2 api-pod uses api-reader-sa serviceAccount" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod api-pod -n api-access -o jsonpath='{.spec.serviceAccountName}' --context cluster1-admin@cluster1)
  if [[ "$result" == "api-reader-sa" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "api-reader-sa" ]
}

@test "17.3 api-pod is running in api-access" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod api-pod -n api-access -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "17.4 /var/work/tests/artifacts/17/response.txt exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(stat /var/work/tests/artifacts/17/response.txt 2>/dev/null && echo ok || echo fail)
  if [[ "$result" == "ok" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ok" ]
}

@test "17.5 response.txt contains PodList" {
  echo '1'>>/var/work/tests/result/all
  cat /var/work/tests/artifacts/17/response.txt | grep -i 'PodList'
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

# 5, 85

# ============================================================
# Task 18 (4 pts): Create ExternalName service external-db in default
# ============================================================

@test "18.1 ExternalName service external-db exists in default" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc external-db -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "external-db" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "external-db" ]
}

@test "18.2 external-db type is ExternalName" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc external-db -o jsonpath='{.spec.type}' --context cluster1-admin@cluster1)
  if [[ "$result" == "ExternalName" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ExternalName" ]
}

@test "18.3 external-db externalName is database.example.com" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc external-db -o jsonpath='{.spec.externalName}' --context cluster1-admin@cluster1)
  if [[ "$result" == "database.example.com" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "database.example.com" ]
}

@test "18.4 external-db is in default namespace" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc external-db -o jsonpath='{.metadata.namespace}' --context cluster1-admin@cluster1)
  if [[ "$result" == "default" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "default" ]
}

# 4, 89

# ============================================================
# Task 19 (4 pts): Create multi-port-pod + multi-port-svc in default
# ============================================================

@test "19.1 pod multi-port-pod exists in default" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod multi-port-pod -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "multi-port-pod" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "multi-port-pod" ]
}

@test "19.2 service multi-port-svc exists in default" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc multi-port-svc -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "multi-port-svc" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "multi-port-svc" ]
}

@test "19.3 multi-port-svc has port 80 named http" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc multi-port-svc -o jsonpath='{.spec.ports[?(@.port==80)].name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "http" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "http" ]
}

@test "19.4 multi-port-svc has port 443 named https" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc multi-port-svc -o jsonpath='{.spec.ports[?(@.port==443)].name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "https" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "https" ]
}

# 4, 93

# ============================================================
# Task 20 (7 pts): Troubleshoot — fix client-pod label so it can reach server-svc
# ============================================================

@test "20.1 client-pod has label role=correct-client" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod client-pod -n trouble-final -o jsonpath='{.metadata.labels.role}' --context cluster1-admin@cluster1)
  if [[ "$result" == "correct-client" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "correct-client" ]
}

@test "20.2 server-pod is running in trouble-final" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod server-pod -n trouble-final -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "20.3 server-svc has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints server-svc -n trouble-final -o jsonpath='{.subsets[0].addresses[0].ip}' --context cluster1-admin@cluster1)
  if [[ -n "$result" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "20.4 allow-client NetworkPolicy still exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy allow-client -n trouble-final -o jsonpath='{.metadata.name}' --context cluster1-admin@cluster1)
  if [[ "$result" == "allow-client" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "allow-client" ]
}

@test "20.5 client-pod is running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod client-pod -n trouble-final -o jsonpath='{.status.phase}' --context cluster1-admin@cluster1)
  if [[ "$result" == "Running" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "20.6 client-pod can curl server-svc" {
  echo '1'>>/var/work/tests/result/all
  kubectl exec client-pod -n trouble-final --context cluster1-admin@cluster1 -- curl http://server-svc --connect-timeout 3 -s
  result=$?
  if [[ "$result" == "0" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "20.7 client-pod curl returns HTTP 200" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl exec client-pod -n trouble-final --context cluster1-admin@cluster1 -- curl http://server-svc -s -o /dev/null -w '%{http_code}' --connect-timeout 3)
  if [[ "$result" == "200" ]]; then
    echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "200" ]
}

# 7, 100
