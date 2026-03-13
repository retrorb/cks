#!/bin/bash
echo " *** worker pc  cka mock-4  "

# Create artifact directories
mkdir -p /var/work/tests/artifacts/{4,7,8,9,16,18,19}
mkdir -p /var/work/tests/result
chmod 777 -R /var/work/tests/artifacts

# Install Helm on worker PC
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update || true

# Create kustomize task13 directory — kustomization.yaml + deployment
mkdir -p /var/work/kustomize/task13
cat > /var/work/kustomize/task13/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF

cat > /var/work/kustomize/task13/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kustomize-app
  namespace: kustomize-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kustomize-app
  template:
    metadata:
      labels:
        app: kustomize-app
    spec:
      containers:
      - name: kustomize-app
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

# Create kustomize task14 base directory
mkdir -p /var/work/kustomize/task14/base
cat > /var/work/kustomize/task14/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
EOF

cat > /var/work/kustomize/task14/base/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: base-deploy
  namespace: overlay-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: base-deploy
  template:
    metadata:
      labels:
        app: base-deploy
    spec:
      containers:
      - name: base-deploy
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# Create overlay dir (student fills in the patch)
mkdir -p /var/work/kustomize/task14/overlay

# Create local helm chart myapp for task 10
mkdir -p /var/work/helm/myapp/templates

cat > /var/work/helm/myapp/Chart.yaml << 'EOF'
apiVersion: v2
name: myapp
description: A simple nginx chart for CKA practice
type: application
version: 0.1.0
appVersion: "1.0"
EOF

cat > /var/work/helm/myapp/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: nginx
  tag: alpine
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
EOF

cat > /var/work/helm/myapp/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-myapp
  namespace: {{ .Release.Namespace }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}-myapp
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-myapp
    spec:
      containers:
      - name: myapp
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 80
EOF

cat > /var/work/helm/myapp/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-myapp-svc
  namespace: {{ .Release.Namespace }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 80
  selector:
    app: {{ .Release.Name }}-myapp
EOF
