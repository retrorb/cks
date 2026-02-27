#!/bin/bash
echo " *** master node  ckad mock-4  k8s-1"
export KUBECONFIG=/root/.kube/config

# Install local-path provisioner for dynamic PVC provisioning (needed for PVC task)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Install metrics-server (needed for kubectl top task)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# task 16 - probe-app deployment (student adds livenessProbe)
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/04/k8s-1/scripts/task16.yaml

# task 17 - startup-app deployment (student adds readiness + startup probes)
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/04/k8s-1/scripts/task17.yaml

# task 18 - broken pod (student fixes it)
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/04/k8s-1/scripts/task18.yaml

# task 20 - deprecated-ns (student applies fixed manifest)
kubectl create namespace deprecated-ns --dry-run=client -o yaml | kubectl apply -f -
