#!/bin/bash
echo " *** master node  ckad mock-3  k8s-1"
export KUBECONFIG=/root/.kube/config

# Install local-path provisioner for dynamic PVC provisioning
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# task 2 - scale-app deployment
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task2.yaml

# task 3 - update-app deployment
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task3.yaml

# task 4 - rollback-app deployment (deploy then update with bad image)
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task4.yaml
kubectl rollout status deployment/rollback-app -n rollback-ns --timeout=60s || true
kubectl set image deployment/rollback-app rollback-app=nginx:this-tag-does-not-exist -n rollback-ns

# task 5 - strategy-app deployment
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task5.yaml

# task 6 - broken-deploy deployment
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task6.yaml

# task 9 - blue/green setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task9.yaml

# task 10 - canary setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task10.yaml

# task 11 - ClusterIP service setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task11.yaml

# task 12 - NodePort service setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task12.yaml

# task 13 - basic ingress setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task13.yaml

# task 14 - multi-path ingress setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task14.yaml

# task 15 - broken ingress setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task15.yaml

# task 16 - NetworkPolicy pods
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task16.yaml

# task 17 - cross-namespace NetworkPolicy setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task17.yaml

# task 18 - broken service setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task18.yaml

# task 19 - headless service setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task19.yaml

# task 20 - final app setup
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/task20.yaml

# task 8 - kustomize namespace
kubectl create namespace kust-ns --dry-run=client -o yaml | kubectl apply -f -

# ingress-nginx installation
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm install ingress-nginx  ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version 4.8.3 \
  -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/ckad/mock/03/k8s-1/scripts/ingress_nginx_conf.yaml

kubectl patch ingressclass nginx --patch '{"metadata": {"annotations": {"ingressclass.kubernetes.io/is-default-class": "true"}}}'
