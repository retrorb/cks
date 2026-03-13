#!/bin/bash
echo " *** master node  mock-6  k8s-1"
export KUBECONFIG=/root/.kube/config

# 1. Install etcdctl for task 3 (etcd backup)
ETCD_VER=v3.5.12
curl -fsSL https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz \
  | tar xz -C /tmp && mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/

# Create artifact directory for task 3 backup (test checks this path via SSH)
mkdir -p /var/work/tests/artifacts/3
chmod 777 -R /var/work/tests/artifacts

# 2. Install metrics-server for task 18 (HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true

# 3. Install ingress-nginx for task 8
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/baremetal/deploy.yaml

# 4. Apply all pre-created task resources
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/cka/mock/06/k8s-1/scripts/task_setup.yaml

# 5. Add taint to first worker node for task 9 (after nodes are ready)
sleep 60
NODE=$(kubectl get nodes -l work_type=infra_core -o jsonpath='{.items[0].name}' 2>/dev/null || true)
if [[ -n "$NODE" ]]; then
  kubectl taint node "$NODE" broken=true:NoSchedule --overwrite || true
fi

# 6. Wait for ingress-nginx to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s || true
