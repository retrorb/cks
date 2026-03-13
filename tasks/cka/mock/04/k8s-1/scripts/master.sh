#!/bin/bash
echo " *** master node  mock-4  k8s-1"
export KUBECONFIG=/root/.kube/config

# 1. Install Helm 3
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 2. Add bitnami repo and install initial my-release for tasks 11/12
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update || true

# 3. Apply all pre-created task resources
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/cka/mock/04/k8s-1/scripts/task_setup.yaml

# 4. Install my-release (nginx) into helm-upgrade-ns for tasks 11/12
kubectl create namespace helm-upgrade-ns --dry-run=client -o yaml | kubectl apply -f -
helm install my-release bitnami/nginx --namespace helm-upgrade-ns || true
