#!/bin/bash
echo " *** master node  mock-7  k8s-1"
export KUBECONFIG=/root/.kube/config

# 1. Install etcdctl v3.5.12 (task 15)
ETCD_VER=v3.5.12
curl -fsSL https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz \
  | tar xz -C /tmp && mv /tmp/etcd-${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/

# 2. Install metrics-server (tasks 7, 20 HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true

# 3. Install Gateway API CRDs v1.1.0 + create GatewayClass (tasks 11, 20)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

# 4. Apply all pre-created task resources
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/cka/mock/07/k8s-1/scripts/task_setup.yaml

# 5. Create GatewayClass after CRDs are ready
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-gw
spec:
  controllerName: example.com/gateway-controller
EOF

# 6. Create broken extra-apiserver static pod with wrong etcd port (task 10)
cat <<'STATICEOF' > /etc/kubernetes/manifests/extra-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: extra-apiserver
  namespace: kube-system
  labels:
    component: extra-apiserver
spec:
  containers:
  - name: extra-apiserver
    image: registry.k8s.io/kube-apiserver:v1.30.0
    command:
    - kube-apiserver
    - --advertise-address=127.0.0.1
    - --etcd-servers=https://127.0.0.1:2399
    - --service-cluster-ip-range=10.96.0.0/12
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.crt
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --secure-port=6444
    volumeMounts:
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
STATICEOF

# 7. Create artifact directories on master
mkdir -p /var/work/tests/artifacts/{10,15}
chmod 777 -R /var/work/tests/artifacts

# 8. Break kubelet cert path on worker node_2 (task 18)
sleep 60
WORKER=$(kubectl get nodes -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || true)
if [[ -n "$WORKER" ]]; then
  ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER} \
    "sudo sed -i 's|tlsCertFile:.*|tlsCertFile: /var/lib/kubelet/pki/kubelet-wrong.crt|' /var/lib/kubelet/config.yaml && sudo systemctl restart kubelet" || true
fi
