#!/bin/bash
echo " *** master node  mock-6  k8s-2"
export KUBECONFIG=/root/.kube/config

# Create correct scheduler config (student will point broken manifest here)
mkdir -p /etc/kubernetes
cat <<'EOF' > /etc/kubernetes/scheduler-config.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: /etc/kubernetes/scheduler.conf
EOF

# Create broken static pod for task 2
cat <<'PODEOF' > /etc/kubernetes/manifests/extra-scheduler.yaml
apiVersion: v1
kind: Pod
metadata:
  name: extra-scheduler
  namespace: kube-system
  labels:
    app: extra-scheduler
spec:
  hostNetwork: true
  priorityClassName: system-node-critical
  containers:
  - name: extra-scheduler
    image: registry.k8s.io/kube-scheduler:v1.30.0
    command:
    - kube-scheduler
    - --config=/nonexistent/scheduler-config.yaml
PODEOF
