#!/bin/bash
echo " *** worker pc mock-3  "
export KUBECONFIG=/root/.kube/config

# Helm installation
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

mkdir -p /opt/logs/
chmod a+w /opt/logs/

address=$(kubectl get no -l work_type=infra_core --context cluster1-admin@cluster1 -o json  | jq -r '.items[] | select(.kind == "Node") | .status.addresses[] | select(.type == "InternalIP") | .address')
echo "$address ckad.local">>/etc/hosts

# Kustomize base files for task 8
mkdir -p /home/ubuntu/kustomize/base

cat > /home/ubuntu/kustomize/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kust-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kust-app
  template:
    metadata:
      labels:
        app: kust-app
    spec:
      containers:
      - name: kust-app
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

cat > /home/ubuntu/kustomize/base/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: kust-svc
spec:
  selector:
    app: kust-app
  ports:
  - port: 80
    targetPort: 80
EOF

cat > /home/ubuntu/kustomize/base/kustomization.yaml << 'EOF'
resources:
- deployment.yaml
- service.yaml
EOF

chown -R ubuntu:ubuntu /home/ubuntu/kustomize/
