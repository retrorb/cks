#!/bin/bash
echo " *** master node  ckad mock-6  k8s-1"
export KUBECONFIG=/root/.kube/config

# Install local-path provisioner for dynamic PVC provisioning
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Add bitnami repo for Helm tasks
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# task 2 - pre-install data-api with replicaCount=1 (student upgrades to 4)
kubectl create namespace helm-api-ns --dry-run=client -o yaml | kubectl apply -f -
helm install data-api bitnami/nginx \
  --namespace helm-api-ns \
  --set replicaCount=1

# task 3 - pre-install report-app with replicaCount=2, then upgrade to broken image (student rolls back)
kubectl create namespace helm-report-ns --dry-run=client -o yaml | kubectl apply -f -
helm install report-app bitnami/nginx \
  --namespace helm-report-ns \
  --set replicaCount=2
sleep 15
helm upgrade report-app bitnami/nginx \
  --namespace helm-report-ns \
  --set replicaCount=1 \
  --set image.tag=thistagdoesnotexist99999

# task 5 - pre-install broken-release with bad image tag (student deletes it and installs fixed-release)
kubectl create namespace helm-broken-ns --dry-run=client -o yaml | kubectl apply -f -
helm install broken-release bitnami/nginx \
  --namespace helm-broken-ns \
  --set image.tag=thistagdoesnotexist99999

# pre-create kustomize namespaces
kubectl create namespace kust2-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace kgen-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace kprod-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace kpatch-ns --dry-run=client -o yaml | kubectl apply -f -

# task 10 - blue/green setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task10.yaml

# task 11 - canary setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task11.yaml

# task 12 - recreate strategy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task12.yaml

# task 13 - deny-all NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task13.yaml

# task 14 - tier NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task14.yaml

# task 15 - egress NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task15.yaml

# task 16 - cross-namespace NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task16.yaml

# task 17 - multi-source NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task17.yaml

# task 18 - egress to pod NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task18.yaml

# task 19 - fix broken NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task19.yaml

# task 20 - TLS Ingress setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task20.yaml

# task 21 - rewrite-target Ingress setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task21.yaml

# task 22 - multi-host Ingress setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task22.yaml

# task 23 - fix ingressClassName setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task23.yaml

# task 24 - ExternalName namespace
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task24.yaml

# task 25 - end-to-end setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/task25.yaml

# ingress-nginx installation
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version 4.8.3 \
  -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/06/k8s-1/scripts/ingress_nginx_conf.yaml

kubectl patch ingressclass nginx --patch '{"metadata": {"annotations": {"ingressclass.kubernetes.io/is-default-class": "true"}}}'
