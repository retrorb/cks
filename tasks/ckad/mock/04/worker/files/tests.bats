#!/usr/bin/env bats
export KUBECONFIG=/home/ubuntu/.kube/_config

@test "0  Init  " {
  echo ''>/var/work/tests/result/all
  echo ''>/var/work/tests/result/ok
  [ "$?" -eq 0 ]

}

# 1 - Build a container image with Podman
@test "1.1 Image myapp:v1 exists in podman" {
  echo '3'>>/var/work/tests/result/all
  result=$(podman images myapp:v1 --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep 'myapp:v1')
  if [[ -n "$result" ]]; then
   echo '3'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "1.2 Running myapp:v1 outputs Hello CKAD" {
  echo '2'>>/var/work/tests/result/all
  result=$(podman run --rm myapp:v1 2>/dev/null)
  if [[ "$result" == "Hello CKAD" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Hello CKAD" ]
}

@test "1.3 Image saved as /home/ubuntu/myapp.tar" {
  echo '1'>>/var/work/tests/result/all
  if [[ -s /home/ubuntu/myapp.tar ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -s /home/ubuntu/myapp.tar ]
}
# 6  6

# 2 - Pod with init container
@test "2.1 Pod init-pod in init-ns has 2 containers (init + main)" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod init-pod -n init-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "2.2 Pod init-pod in init-ns. init container image=busybox" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod init-pod -n init-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.initContainers[0].image}' 2>/dev/null)
  if [[ "$result" == "busybox" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "busybox" ]
}

@test "2.3 Pod init-pod is Running" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod init-pod -n init-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}')
  if [[ "$result" == "Running" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}
# 4  10

# 3 - Pod with sidecar
@test "3.1 Pod shared-pod in sidecar-ns has 2 containers" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod shared-pod -n sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers}' 2>/dev/null | jq 'length')
  if [[ "$result" == "2" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}

@test "3.2 Pod shared-pod has emptyDir volume named shared-data" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get pod shared-pod -n sidecar-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.volumes[?(@.name=="shared-data")].emptyDir}')
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "3.3 Pod shared-pod reader container can read from shared volume" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl exec shared-pod -c reader -n sidecar-ns --context cluster1-admin@cluster1 -- cat /shared/data.txt 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 4  14

# 4 - CronJob
@test "4.1 CronJob backup-job in cron-ns. schedule=*/5 * * * *" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get cronjob backup-job -n cron-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.schedule}')
  if [[ "$result" == "*/5 * * * *" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "*/5 * * * *" ]
}

@test "4.2 CronJob backup-job. concurrencyPolicy=Forbid" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get cronjob backup-job -n cron-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.concurrencyPolicy}')
  if [[ "$result" == "Forbid" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Forbid" ]
}

@test "4.3 CronJob backup-job. successfulJobsHistoryLimit=3" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get cronjob backup-job -n cron-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.successfulJobsHistoryLimit}')
  if [[ "$result" == "3" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}
# 6  20

# 5 - Job with parallelism
@test "5.1 Job batch-job in jobs-ns. completions=8" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get job batch-job -n jobs-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.completions}')
  if [[ "$result" == "8" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "8" ]
}

@test "5.2 Job batch-job. parallelism=4" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get job batch-job -n jobs-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.parallelism}')
  if [[ "$result" == "4" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "4" ]
}

@test "5.3 Job batch-job. backoffLimit=3" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get job batch-job -n jobs-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.backoffLimit}')
  if [[ "$result" == "3" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "3" ]
}

@test "5.4 Job batch-job. image=busybox" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get job batch-job -n jobs-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [[ "$result" == "busybox" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "busybox" ]
}
# 4  24

# 6 - PVC and Pod
@test "6.1 PVC data-pvc in storage-ns. storage=100Mi" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pvc data-pvc -n storage-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.resources.requests.storage}')
  if [[ "$result" == "100Mi" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "100Mi" ]
}

@test "6.2 Pod storage-pod in storage-ns mounts PVC at /data" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod storage-pod -n storage-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/data")].name}')
  if [[ -n "$result" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "6.3 Pod storage-pod is Running" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod storage-pod -n storage-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}')
  if [[ "$result" == "Running" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}
# 6  30

# 7 - DaemonSet
@test "7.1 DaemonSet log-collector in ds-ns. image=busybox" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get daemonset log-collector -n ds-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].image}')
  if [[ "$result" == "busybox" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "busybox" ]
}

@test "7.2 DaemonSet log-collector has toleration for control-plane" {
  echo '1'>>/var/work/tests/result/all
  kubectl get daemonset log-collector -n ds-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.tolerations}' | grep -i 'control-plane'
  result=$?
  if [[ "$result" == "0" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "0" ]
}

@test "7.3 DaemonSet log-collector runs on all nodes" {
  echo '2'>>/var/work/tests/result/all
  total_nodes=$(kubectl get nodes --context cluster1-admin@cluster1 --no-headers | wc -l | tr -d ' ')
  ds_ready=$(kubectl get daemonset log-collector -n ds-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.numberReady}')
  if [[ "$ds_ready" == "$total_nodes" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$ds_ready" == "$total_nodes" ]
}
# 4  34

# 8 - ConfigMap as env vars and volume
@test "8.1 ConfigMap app-config in config-ns. APP_ENV=production" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get configmap app-config -n config-ns --context cluster1-admin@cluster1 -o jsonpath='{.data.APP_ENV}')
  if [[ "$result" == "production" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "production" ]
}

@test "8.2 Pod config-pod in config-ns uses APP_ENV env from configmap" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod config-pod -n config-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].env[?(@.name=="APP_ENV")].valueFrom.configMapKeyRef.name}')
  if [[ "$result" == "app-config" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-config" ]
}

@test "8.3 Pod config-pod mounts configmap at /etc/config" {
  echo '3'>>/var/work/tests/result/all
  result=$(kubectl exec config-pod -n config-ns --context cluster1-admin@cluster1 -- ls /etc/config/APP_ENV 2>/dev/null)
  if [[ -n "$result" ]]; then
   echo '3'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 6  40

# 9 - Secret as volume
@test "9.1 Secret db-secret in secret-ns. DB_USER=admin" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get secret db-secret -n secret-ns --context cluster1-admin@cluster1 -o jsonpath='{.data.DB_USER}' | base64 --decode)
  if [[ "$result" == "admin" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "admin" ]
}

@test "9.2 Pod secret-pod mounts secret at /etc/secrets" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod secret-pod -n secret-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.volumes[?(@.secret.secretName=="db-secret")].name}')
  if [[ -n "$result" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}

@test "9.3 Pod secret-pod can read DB_USER from /etc/secrets" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl exec secret-pod -n secret-ns --context cluster1-admin@cluster1 -- cat /etc/secrets/DB_USER 2>/dev/null)
  if [[ "$result" == "admin" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "admin" ]
}
# 4  44

# 10 - SecurityContext
@test "10.1 Pod secure-pod in security-ns. runAsUser=1000" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod secure-pod -n security-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.securityContext.runAsUser}')
  if [[ "$result" == "1000" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "1000" ]
}

@test "10.2 Pod secure-pod. container allowPrivilegeEscalation=false" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod secure-pod -n security-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}')
  if [[ "$result" == "false" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "false" ]
}

@test "10.3 Pod secure-pod. container readOnlyRootFilesystem=true" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod secure-pod -n security-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].securityContext.readOnlyRootFilesystem}')
  if [[ "$result" == "true" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "true" ]
}

@test "10.4 Pod secure-pod drops ALL capabilities" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod secure-pod -n security-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop}' | grep -i 'ALL')
  if [[ -n "$result" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 8  52

# 11 - RBAC
@test "11.1 ServiceAccount app-sa in rbac-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get sa app-sa -n rbac-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}')
  if [[ "$result" == "app-sa" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-sa" ]
}

@test "11.2 Role deploy-reader in rbac-ns. resource=deployments verbs include get,list" {
  echo '2'>>/var/work/tests/result/all
  kubectl get role deploy-reader -n rbac-ns --context cluster1-admin@cluster1 -o jsonpath='{.rules[*].resources}' | grep 'deployments'
  res1=$?
  kubectl get role deploy-reader -n rbac-ns --context cluster1-admin@cluster1 -o jsonpath='{.rules[*].verbs}' | grep 'list'
  res2=$?
  if [[ "$res1" == "0" && "$res2" == "0" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$res1" == "0" ]
  [ "$res2" == "0" ]
}

@test "11.3 RoleBinding app-sa-binding binds app-sa to deploy-reader" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get rolebinding app-sa-binding -n rbac-ns --context cluster1-admin@cluster1 -o jsonpath='{.subjects[?(.kind=="ServiceAccount")].name}')
  if [[ "$result" == "app-sa" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-sa" ]
}

@test "11.4 Pod rbac-pod in rbac-ns uses SA app-sa" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod rbac-pod -n rbac-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.serviceAccountName}')
  if [[ "$result" == "app-sa" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "app-sa" ]
}
# 8  60

# 12 - ResourceQuota
@test "12.1 ResourceQuota ns-quota in quota-ns. pods=10" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get resourcequota ns-quota -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.hard.pods}')
  if [[ "$result" == "10" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "10" ]
}

@test "12.2 ResourceQuota ns-quota. requests.cpu=2" {
  echo '1'>>/var/work/tests/result/all
  result=$(kubectl get resourcequota ns-quota -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.hard.requests\.cpu}')
  if [[ "$result" == "2" ]]; then
   echo '1'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2" ]
}

@test "12.3 ResourceQuota ns-quota. limits.memory=2Gi" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get resourcequota ns-quota -n quota-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.hard.limits\.memory}')
  if [[ "$result" == "2Gi" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "2Gi" ]
}
# 4  64

# 13 - LimitRange
@test "13.1 LimitRange default-limits in limits-ns. default cpu limit=200m" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get limitrange default-limits -n limits-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.limits[?(@.type=="Container")].default.cpu}')
  if [[ "$result" == "200m" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "200m" ]
}

@test "13.2 LimitRange default-limits. default memory limit=256Mi" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get limitrange default-limits -n limits-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.limits[?(@.type=="Container")].default.memory}')
  if [[ "$result" == "256Mi" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "256Mi" ]
}
# 4  68

# 14 - CRD and CR
@test "14.1 CRD foos.example.com exists in cluster" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get crd foos.example.com --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "foos.example.com" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "foos.example.com" ]
}

@test "14.2 Custom resource my-foo exists in crd-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get foo my-foo -n crd-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "my-foo" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "my-foo" ]
}
# 4  72

# 15 - ServiceAccount in Pod
@test "15.1 ServiceAccount my-sa exists in sa-ns" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get sa my-sa -n sa-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}')
  if [[ "$result" == "my-sa" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "my-sa" ]
}

@test "15.2 Pod sa-pod in sa-ns uses ServiceAccount my-sa" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod sa-pod -n sa-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.serviceAccountName}')
  if [[ "$result" == "my-sa" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "my-sa" ]
}
# 4  76

# 16 - Liveness probe
@test "16.1 Deployment probe-app in probe-ns has livenessProbe httpGet /health:8080" {
  echo '2'>>/var/work/tests/result/all
  path=$(kubectl get deployment probe-app -n probe-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}')
  port=$(kubectl get deployment probe-app -n probe-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.port}')
  if [[ "$path" == "/health" && "$port" == "8080" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$path" == "/health" ]
  [ "$port" == "8080" ]
}

@test "16.2 Deployment probe-app livenessProbe. initialDelaySeconds=10 periodSeconds=5" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get deployment probe-app -n probe-ns --context cluster1-admin@cluster1 -o json | jq -r '"\(.spec.template.spec.containers[0].livenessProbe.initialDelaySeconds) \(.spec.template.spec.containers[0].livenessProbe.periodSeconds)"')
  if [[ "$result" == "10 5" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "10 5" ]
}
# 4  80

# 17 - Readiness and startup probes
@test "17.1 Deployment startup-app in startup-ns has readinessProbe httpGet /health:8080" {
  echo '2'>>/var/work/tests/result/all
  path=$(kubectl get deployment startup-app -n startup-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')
  port=$(kubectl get deployment startup-app -n startup-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}')
  if [[ "$path" == "/health" && "$port" == "8080" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$path" == "/health" ]
  [ "$port" == "8080" ]
}

@test "17.2 Deployment startup-app has startupProbe httpGet /health:8080 failureThreshold=30" {
  echo '2'>>/var/work/tests/result/all
  path=$(kubectl get deployment startup-app -n startup-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].startupProbe.httpGet.path}')
  ft=$(kubectl get deployment startup-app -n startup-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.template.spec.containers[0].startupProbe.failureThreshold}')
  if [[ "$path" == "/health" && "$ft" == "30" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$path" == "/health" ]
  [ "$ft" == "30" ]
}
# 4  84

# 18 - Debug and fix failing pod
@test "18.1 Pod broken-pod in debug-ns is Running" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod broken-pod -n debug-ns --context cluster1-admin@cluster1 -o jsonpath='{.status.phase}')
  if [[ "$result" == "Running" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" == "Running" ]
}

@test "18.2 Pod broken-pod in debug-ns. command=sleep 3600" {
  echo '2'>>/var/work/tests/result/all
  result=$(kubectl get pod broken-pod -n debug-ns --context cluster1-admin@cluster1 -o jsonpath='{.spec.containers[0].command}' 2>/dev/null | grep -c 'sleep')
  if [[ "$result" -ge "1" ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ "$result" -ge "1" ]
}
# 4  88

# 19 - Monitor resource usage
@test "19.1 File /home/ubuntu/top-nodes.txt exists and is non-empty" {
  echo '2'>>/var/work/tests/result/all
  if [[ -s /home/ubuntu/top-nodes.txt ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -s /home/ubuntu/top-nodes.txt ]
}

@test "19.2 File /home/ubuntu/top-pods.txt exists and is non-empty" {
  echo '2'>>/var/work/tests/result/all
  if [[ -s /home/ubuntu/top-pods.txt ]]; then
   echo '2'>>/var/work/tests/result/ok
  fi
  [ -s /home/ubuntu/top-pods.txt ]
}
# 4  92

# 20 - Fix deprecated API
@test "20.1 CronJob old-job exists in deprecated-ns" {
  echo '4'>>/var/work/tests/result/all
  result=$(kubectl get cronjob old-job -n deprecated-ns --context cluster1-admin@cluster1 -o jsonpath='{.metadata.name}' 2>/dev/null)
  if [[ "$result" == "old-job" ]]; then
   echo '4'>>/var/work/tests/result/ok
  fi
  [ "$result" == "old-job" ]
}

@test "20.2 File /home/ubuntu/deprecated.yaml uses current API version batch/v1" {
  echo '4'>>/var/work/tests/result/all
  result=$(grep 'apiVersion:' /home/ubuntu/deprecated.yaml | grep 'batch/v1$')
  if [[ -n "$result" ]]; then
   echo '4'>>/var/work/tests/result/ok
  fi
  [ -n "$result" ]
}
# 8  100
