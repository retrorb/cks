#!/bin/bash
echo " *** master node  mock-5  k8s-1"
export KUBECONFIG=/root/.kube/config

# 1. Install metrics-server for kubectl top (tasks 7/8)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# Patch for insecure TLS in lab environment
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true

# 2. Install ingress-nginx (for task 14)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/baremetal/deploy.yaml

# 3. Apply all pre-created task resources (broken objects)
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/cka/mock/05/k8s-1/scripts/task_setup.yaml

# 4. Add taint to worker node for tasks 1 and 16
NODE=$(kubectl get nodes -l work_type=infra_core -o jsonpath='{.items[0].name}')
kubectl taint node $NODE broken=true:NoSchedule --overwrite || true

NODE2=$(kubectl get nodes -l work_type=infra_core -o jsonpath='{.items[1].name}' 2>/dev/null || true)
if [[ -n "$NODE2" ]]; then
  kubectl taint node $NODE2 maintenance=true:NoExecute --overwrite || true
fi

# 5. Create broken static pod for task 2
cat <<'PODEOF' > /etc/kubernetes/manifests/broken-scheduler.yaml
apiVersion: v1
kind: Pod
metadata:
  name: broken-scheduler
  namespace: kube-system
spec:
  hostNetwork: true
  containers:
  - name: broken-scheduler
    image: registry.k8s.io/kube-scheduler:v1.30.0
    command:
    - kube-scheduler
    - --config=/nonexistent/scheduler-config.yaml
PODEOF

# Create correct scheduler config for task 2 (student will fix path to point here)
mkdir -p /etc/kubernetes
cat <<'CONFIGEOF' > /etc/kubernetes/scheduler-config.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: /etc/kubernetes/scheduler.conf
CONFIGEOF

# 6. Wait for ingress-nginx
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s || true
