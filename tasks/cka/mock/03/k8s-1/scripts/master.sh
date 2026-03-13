#!/bin/bash
echo " *** master node  mock-3  k8s-1"
export KUBECONFIG=/root/.kube/config

# 1. Install ingress-nginx (NodePort / baremetal mode)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/baremetal/deploy.yaml

# 2. Install Gateway API standard CRDs (v1.1.0)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

# 3. Apply all pre-created task resources (namespaces, deployments, services, broken objects)
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/cka/mock/03/k8s-1/scripts/task_setup.yaml

# 4. Wait for ingress-nginx controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s || true
