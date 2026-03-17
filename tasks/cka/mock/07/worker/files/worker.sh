#!/bin/bash
echo " *** worker pc  cka mock-7  "

# Create artifact directories
mkdir -p /var/work/tests/artifacts/{2,3,4,9,10,14,15,17,20}
mkdir -p /var/work/tests/result
chmod 777 -R /var/work/tests/artifacts

# Create Helm chart: analytics (task 1)
mkdir -p /var/work/helm/analytics/templates
cat <<'EOF' > /var/work/helm/analytics/Chart.yaml
apiVersion: v2
name: analytics
description: Analytics application chart
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

cat <<'EOF' > /var/work/helm/analytics/values.yaml
image:
  repository: nginx
  tag: latest
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
replicaCount: 1
EOF

cat <<'EOF' > /var/work/helm/analytics/templates/deployment.yaml
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

cat <<'EOF' > /var/work/helm/analytics/templates/service.yaml
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

# Create Helm chart: metrics-dash (task 9)
mkdir -p /var/work/helm/metrics-dash/templates
cat <<'EOF' > /var/work/helm/metrics-dash/Chart.yaml
apiVersion: v2
name: metrics-dash
description: Metrics dashboard chart
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

cat <<'EOF' > /var/work/helm/metrics-dash/values.yaml
image:
  repository: nginx
  tag: alpine
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
replicaCount: 1
EOF

cat <<'EOF' > /var/work/helm/metrics-dash/templates/deployment.yaml
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

cat <<'EOF' > /var/work/helm/metrics-dash/templates/service.yaml
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

cat <<'EOF' > /var/work/helm/metrics-dash/custom-values.yaml
image:
  repository: grafana/grafana
  tag: 10.0.0
service:
  port: 3000
replicaCount: 2
EOF

# Install metrics-dash release (task 9 — student templates + checks deployed image)
helm install metrics-dash /var/work/helm/metrics-dash -n helm-tpl-ns --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 || true

# Install broken-release in helm-fix-ns (task 14)
# Rev 1: default (replicas=1)
helm install broken-release /var/work/helm/analytics -n helm-fix-ns --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 || true
# Rev 2: good (replicas=3)
helm upgrade broken-release /var/work/helm/analytics -n helm-fix-ns --set replicaCount=3 --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 || true
# Rev 3: bad (replicas=0)
helm upgrade broken-release /var/work/helm/analytics -n helm-fix-ns --set replicaCount=0 --kubeconfig /home/ubuntu/.kube/_config --kube-context cluster1-admin@cluster1 || true

# Add /etc/hosts entries for ingress/gateway testing
address=$(kubectl get no -l work_type=infra_core --context cluster1-admin@cluster1 --kubeconfig /home/ubuntu/.kube/_config -o json 2>/dev/null | jq -r '.items[0].status.addresses[] | select(.type == "InternalIP") | .address' 2>/dev/null || true)
if [[ -n "$address" ]]; then
  echo "$address api.cluster1.local app.cluster1.local" >>/etc/hosts
fi
