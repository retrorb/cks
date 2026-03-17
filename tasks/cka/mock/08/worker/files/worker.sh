#!/bin/bash
echo " *** worker pc  cka mock-8  "

# Create artifact directories
mkdir -p /var/work/tests/artifacts/{1,2,8,10,11,14,15,16,17,19}
mkdir -p /var/work/tests/result
chmod 777 -R /var/work/tests/artifacts

# Add helm repo for task 1
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --kubeconfig /home/ubuntu/.kube/_config || true
helm repo update --kubeconfig /home/ubuntu/.kube/_config || true

# Create Helm chart: webapp (task 11)
mkdir -p /var/work/helm/webapp/templates
cat <<'EOF' > /var/work/helm/webapp/Chart.yaml
apiVersion: v2
name: webapp
description: Web application chart
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

cat <<'EOF' > /var/work/helm/webapp/values.yaml
image:
  repository: nginx
  tag: alpine
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
replicaCount: 1
EOF

cat <<'EOF' > /var/work/helm/webapp/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: {{ .Release.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.port }}
EOF

cat <<'EOF' > /var/work/helm/webapp/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-svc
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Release.Name }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.port }}
EOF

cat <<'EOF' > /var/work/helm/webapp/prod-values.yaml
image:
  repository: httpd
  tag: "2.4"
service:
  port: 8080
replicaCount: 3
EOF

# Create TLS secret for task 19
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/secure-tls.key -out /tmp/secure-tls.crt \
  -subj "/CN=secure.cluster1.local" 2>/dev/null || true
kubectl create secret tls secure-tls --cert=/tmp/secure-tls.crt --key=/tmp/secure-tls.key \
  -n gw-secure-ns --kubeconfig /home/ubuntu/.kube/_config --context cluster1-admin@cluster1 2>/dev/null || true

# Add /etc/hosts entries
address=$(kubectl get no -l work_type=infra_core --context cluster1-admin@cluster1 --kubeconfig /home/ubuntu/.kube/_config -o json 2>/dev/null | jq -r '.items[0].status.addresses[] | select(.type == "InternalIP") | .address' 2>/dev/null || true)
if [[ -n "$address" ]]; then
  echo "$address products.cluster1.local secure.cluster1.local" >>/etc/hosts
fi
