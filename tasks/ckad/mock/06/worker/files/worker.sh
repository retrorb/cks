#!/bin/bash
echo " *** worker pc mock-6  "
export KUBECONFIG=/root/.kube/config

# Helm installation
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

mkdir -p /opt/logs/
chmod a+w /opt/logs/

address=$(kubectl get no -l work_type=infra_core --context cluster1-admin@cluster1 -o json | jq -r '.items[] | select(.kind == "Node") | .status.addresses[] | select(.type == "InternalIP") | .address')
echo "$address bg.example.com app2.example.com secure.example.com webfix.example.com blog.example.com shop.example.com full.example.com" >> /etc/hosts

# Task 4: Helm values file for metrics-web install
mkdir -p /home/ubuntu/helm-values
cat > /home/ubuntu/helm-values/metrics.yaml << 'EOF'
replicaCount: 2
service:
  type: ClusterIP
EOF

# Task 6: Kustomize base for image overlay task
mkdir -p /home/ubuntu/kust2/base
cat > /home/ubuntu/kust2/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kust2-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kust2-app
  template:
    metadata:
      labels:
        app: kust2-app
    spec:
      containers:
      - name: kust2-app
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF
cat > /home/ubuntu/kust2/base/kustomization.yaml << 'EOF'
resources:
- deployment.yaml
EOF

# Task 8: Kustomize base for namePrefix + commonLabels task
mkdir -p /home/ubuntu/kust4/base
cat > /home/ubuntu/kust4/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kust4-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kust4-app
  template:
    metadata:
      labels:
        app: kust4-app
    spec:
      containers:
      - name: kust4-app
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF
cat > /home/ubuntu/kust4/base/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: kust4-svc
spec:
  selector:
    app: kust4-app
  ports:
  - port: 80
    targetPort: 80
EOF
cat > /home/ubuntu/kust4/base/kustomization.yaml << 'EOF'
resources:
- deployment.yaml
- service.yaml
EOF

# Task 9: Kustomize base for strategic merge patch task
mkdir -p /home/ubuntu/kust5/base
cat > /home/ubuntu/kust5/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cache-app
  template:
    metadata:
      labels:
        app: cache-app
    spec:
      containers:
      - name: cache-app
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF
cat > /home/ubuntu/kust5/base/kustomization.yaml << 'EOF'
resources:
- deployment.yaml
EOF

# Task 20: Generate self-signed TLS certificate
mkdir -p /home/ubuntu/tls
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /home/ubuntu/tls/tls.key \
  -out /home/ubuntu/tls/tls.crt \
  -subj "/CN=secure.example.com" 2>/dev/null

chown -R ubuntu:ubuntu /home/ubuntu/helm-values/ \
  /home/ubuntu/kust2/ \
  /home/ubuntu/kust4/ \
  /home/ubuntu/kust5/ \
  /home/ubuntu/tls/
