#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]

}

# 1  - Create a Deployment
@test "1.1 Namespace deploy-ns exists" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace deploy-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}')
  if [[ "$result" == "deploy-ns" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deploy-ns" ]
}

@test "1.2 Deployment web-app in deploy-ns. image=nginx:alpine" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment web-app -n deploy-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [[ "$result" == "nginx:alpine" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "1.3 Deployment web-app in deploy-ns. replicas=3" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment web-app -n deploy-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.replicas}')
  if [[ "$result" == "3" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}

@test "1.4 Deployment web-app in deploy-ns. readyReplicas=3" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment web-app -n deploy-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.readyReplicas}')
  if [[ "$result" == "3" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}
# 4  4

# 2  - Scale a Deployment
@test "2.1 Deployment scale-app in scale-ns. spec.replicas=4" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment scale-app -n scale-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.replicas}')
  if [[ "$result" == "4" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "4" ]
}

@test "2.2 Deployment scale-app in scale-ns. readyReplicas=4" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment scale-app -n scale-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.readyReplicas}')
  if [[ "$result" == "4" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "4" ]
}
# 2  6

# 3  - Update a Deployment image
@test "3.1 Deployment update-app in update-ns. image=nginx:alpine" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment update-app -n update-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [[ "$result" == "nginx:alpine" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "3.2 Deployment update-app in update-ns. readyReplicas>=1" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment update-app -n update-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.readyReplicas}')
  if [[ "$result" -ge "1" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}
# 4  10

# 4  - Rollback a Deployment
@test "4.1 Deployment rollback-app in rollback-ns. image=nginx:alpine" {
  echo '3'>>/var/work/tests/result/all
  result=$(kubectl get deployment rollback-app -n rollback-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [[ "$result" == "nginx:alpine" ]]; then
   echo '3'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "4.2 Deployment rollback-app in rollback-ns. readyReplicas=2" {
  echo '3'>>/var/work/tests/result/all
  result=$(kubectl get deployment rollback-app -n rollback-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.readyReplicas}')
  if [[ "$result" == "2" ]]; then
   echo '3'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}
# 6  16

# 5  - Configure rolling update strategy
@test "5.1 Deployment strategy-app in strategy-ns. strategy.type=RollingUpdate" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment strategy-app -n strategy-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.strategy.type}')
  if [[ "$result" == "RollingUpdate" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "RollingUpdate" ]
}

@test "5.2 Deployment strategy-app in strategy-ns. maxSurge=1" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment strategy-app -n strategy-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')
  if [[ "$result" == "1" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "1" ]
}

@test "5.3 Deployment strategy-app in strategy-ns. maxUnavailable=0" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get deployment strategy-app -n strategy-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')
  if [[ "$result" == "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}
# 4  20

# 6  - Fix a broken Deployment
@test "6.1 Deployment broken-deploy in broken-ns. image=nginx:alpine" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment broken-deploy -n broken-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [[ "$result" == "nginx:alpine" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "nginx:alpine" ]
}

@test "6.2 Deployment broken-deploy in broken-ns. readyReplicas=2" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment broken-deploy -n broken-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.readyReplicas}')
  if [[ "$result" == "2" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}
# 4  24

# 7  - Helm install
@test "7.1 Helm release nginx-web exists in helm-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(helm list -n helm-ns --kube-context cluster1-admin@cluster1 -q 2>/dev/null | grep 'nginx-web')
  if [[ -n "$result" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "7.2 Helm release nginx-web status=deployed" {
  echo '2'>>/var/work/tests/result/all
  result=$(helm list -n helm-ns --kube-context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.[] | select(.name=="nginx-web") | .status')
  if [[ "$result" == "deployed" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "deployed" ]
}

@test "7.3 Helm nginx-web pods running in helm-ns. count>=2" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pods -n helm-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | grep -c 'Running')
  if [[ "$result" -ge "2" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "2" ]
}

@test "7.4 Helm nginx-web service exists in helm-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get svc -n helm-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}
# 8  32

# 8  - Kustomize
@test "8.1 Namespace kust-ns exists" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get namespace kust-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}')
  if [[ "$result" == "kust-ns" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "kust-ns" ]
}

@test "8.2 Kustomize deployment exists in kust-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment -n kust-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "8.3 Kustomize deployment in kust-ns. replicas=3" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment -n kust-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].spec.replicas}')
  if [[ "$result" == "3" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}

@test "8.4 Kustomize deployment in kust-ns. readyReplicas=3" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment -n kust-ns --context cluster1-admin@cluster1 -o jsonpath='{.items[0].status.readyReplicas}')
  if [[ "$result" == "3" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}
# 8  40

# 9  - Blue/Green deployment
@test "9.1 Deployment app-green exists in bg-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment app-green -n bg-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "app-green" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-green" ]
}

@test "9.2 Deployment app-green in bg-ns. image=viktoruj/ping_pong:alpine" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment app-green -n bg-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
  if [[ "$result" == "viktoruj/ping_pong:alpine" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "viktoruj/ping_pong:alpine" ]
}

@test "9.3 Service app-svc in bg-ns. selector version=green" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get svc app-svc -n bg-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.selector.version}')
  if [[ "$result" == "green" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "green" ]
}

@test "9.4 Service app-svc in bg-ns has endpoints for green pods" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get endpoints app-svc -n bg-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 8  48

# 10  - Canary deployment
@test "10.1 Deployment canary-app exists in canary-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment canary-app -n canary-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "canary-app" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "canary-app" ]
}

@test "10.2 Deployment canary-app in canary-ns. replicas=1" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment canary-app -n canary-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.replicas}')
  if [[ "$result" == "1" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "1" ]
}

@test "10.3 Deployment canary-app in canary-ns has label app=frontend (matches service selector)" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment canary-app -n canary-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.metadata.labels.app}')
  if [[ "$result" == "frontend" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "frontend" ]
}
# 6  54

# 11  - ClusterIP Service
@test "11.1 Service web-svc in svc-ns. type=ClusterIP" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc web-svc -n svc-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.type}')
  if [[ "$result" == "ClusterIP" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "ClusterIP" ]
}

@test "11.2 Service web-svc in svc-ns has endpoints" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get endpoints web-svc -n svc-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 2  56

# 12  - NodePort Service
@test "12.1 Service np-svc in np-ns. type=NodePort" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc np-svc -n np-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.type}')
  if [[ "$result" == "NodePort" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "NodePort" ]
}

@test "12.2 Service np-svc in np-ns. nodePort=30091" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get svc np-svc -n np-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ports[0].nodePort}')
  if [[ "$result" == "30091" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "30091" ]
}
# 2  58

# 13  - Basic Ingress
@test "13.1 Ingress web-ingress exists in ingress-basic-ns with host web.example.com" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get ingress web-ingress -n ingress-basic-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].host}')
  if [[ "$result" == "web.example.com" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "web.example.com" ]
}

@test "13.2 Ingress web-ingress in ingress-basic-ns. backend=web-svc:80" {
  echo '2'>>/var/work/tests/result/all
  svc=$(kubectl get ingress web-ingress -n ingress-basic-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
  port=$(kubectl get ingress web-ingress -n ingress-basic-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
  if [[ "$svc" == "web-svc" && "$port" == "80" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$svc" == "web-svc" ]
  [ "$port" == "80" ]
}
# 4  62

# 14  - Multi-path Ingress
@test "14.1 Ingress multi-ingress exists in ingress-multi-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get ingress multi-ingress -n ingress-multi-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "multi-ingress" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "multi-ingress" ]
}

@test "14.2 Ingress multi-ingress in ingress-multi-ns. path /api -> api-svc:8080" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get ingress multi-ingress -n ingress-multi-ns --context cluster1-admin@cluster1 -o json | jq -r '.spec.rules[].http.paths[] | select(.path=="/api") | .backend.service.name')
  if [[ "$result" == "api-svc" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "api-svc" ]
}

@test "14.3 Ingress multi-ingress in ingress-multi-ns. path /web -> web-svc:80" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get ingress multi-ingress -n ingress-multi-ns --context cluster1-admin@cluster1 -o json | jq -r '.spec.rules[].http.paths[] | select(.path=="/web") | .backend.service.name')
  if [[ "$result" == "web-svc" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "web-svc" ]
}
# 6  68

# 15  - Fix broken Ingress
@test "15.1 Ingress broken-ingress in ingress-fix-ns. backend=correct-svc" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
  if [[ "$result" == "correct-svc" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "correct-svc" ]
}

@test "15.2 Ingress broken-ingress in ingress-fix-ns. backend port=80" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get ingress broken-ingress -n ingress-fix-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
  if [[ "$result" == "80" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "80" ]
}
# 4  72

# 16  - NetworkPolicy
@test "16.1 NetworkPolicy exists in netpol-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n netpol-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "16.2 NetworkPolicy - frontend pod can reach backend on port 8080" {
  echo '4'>>/var/work/tests/result/all
  backend_ip=$(kubectl get pod backend -n netpol-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}')
  kubectl exec frontend -n netpol-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$backend_ip:8080"
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '4'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "16.3 NetworkPolicy - other pod cannot reach backend on port 8080" {
  echo '3'>>/var/work/tests/result/all
  set +e
  backend_ip=$(kubectl get pod backend -n netpol-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.podIP}')
  kubectl exec other -n netpol-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$backend_ip:8080"
  result=$?
  set -e
  if [[ "$result" != "0" ]]; then
   echo '3'>>/var/work/tests/result/ok
  fi
  [ "$result" != "0" ]
}
# 8  80

# 17  - Cross-namespace NetworkPolicy
@test "17.1 NetworkPolicy exists in app-ns" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get networkpolicy -n app-ns --context cluster1-admin@cluster1 --no-headers 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$result" -ge "1" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}

@test "17.2 Namespace trusted-ns has label access=trusted" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get namespace trusted-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.labels.access}')
  if [[ "$result" == "trusted" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "trusted" ]
}

@test "17.3 Pod in trusted-ns can reach webapp in app-ns on port 8080" {
  echo '3'>>/var/work/tests/result/all
  webapp_ip=$(kubectl get pod -n app-ns --context cluster1-admin@cluster1 -l app=webapp -o jsonpath='{.items[0].status.podIP}')
  kubectl exec test-pod -n trusted-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$webapp_ip:8080"
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '3'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "17.4 Pod in untrusted-ns cannot reach webapp in app-ns on port 8080" {
  echo '1'>>/var/work/tests/result/all
  set +e
  webapp_ip=$(kubectl get pod -n app-ns --context cluster1-admin@cluster1 -l app=webapp -o jsonpath='{.items[0].status.podIP}')
  kubectl exec test-pod -n untrusted-ns --context cluster1-admin@cluster1 -- wget -q --timeout=5 -O- "http://$webapp_ip:8080"
  result=$?
  set -e
  if [[ "$result" != "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" != "0" ]
}
# 6  86

# 18  - Fix broken Service
@test "18.1 Service web-svc in svc-fix-ns. selector app=web-v2" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get svc web-svc -n svc-fix-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.selector.app}')
  if [[ "$result" == "web-v2" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "web-v2" ]
}

@test "18.2 Service web-svc in svc-fix-ns has endpoints" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get endpoints web-svc -n svc-fix-ns --context cluster1-admin@cluster1 -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  90

# 19  - Headless Service
@test "19.1 Service db-headless in headless-ns. clusterIP=None" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get svc db-headless -n headless-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.clusterIP}')
  if [[ "$result" == "None" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "None" ]
}

@test "19.2 Service db-headless in headless-ns. selector app=db-stateful" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get svc db-headless -n headless-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.selector.app}')
  if [[ "$result" == "db-stateful" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "db-stateful" ]
}
# 4  94

# 20  - Service + Ingress combination
@test "20.1 Service final-svc in final-ns. type=ClusterIP port=80" {
  echo '2'>>/var/work/tests/result/all
  port=$(kubectl get svc final-svc -n final-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.ports[0].port}')
  if [[ "$port" == "80" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$port" == "80" ]
}

@test "20.2 Ingress final-ingress in final-ns. host=final.example.com" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get ingress final-ingress -n final-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].host}')
  if [[ "$result" == "final.example.com" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "final.example.com" ]
}

@test "20.3 Ingress final-ingress in final-ns. backend=final-svc:80" {
  echo '2'>>/var/work/tests/result/all
  svc=$(kubectl get ingress final-ingress -n final-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
  port=$(kubectl get ingress final-ingress -n final-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}')
  if [[ "$svc" == "final-svc" && "$port" == "80" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$svc" == "final-svc" ]
  [ "$port" == "80" ]
}
# 6  100
