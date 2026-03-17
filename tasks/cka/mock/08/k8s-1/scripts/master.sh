#!/bin/bash
echo " *** master node  mock-8  k8s-1"
export KUBECONFIG=/root/.kube/config

# 1. Install metrics-server (tasks 5, 18 HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true

# 2. Install Gateway API CRDs v1.1.0 (tasks 7, 19)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

# 3. Apply all pre-created task resources
kubectl apply -f https://raw.githubusercontent.com/retrorb/cks/master/tasks/cka/mock/08/k8s-1/scripts/task_setup.yaml

# 4. Create GatewayClass after CRDs are ready
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-gw
spec:
  controllerName: example.com/gateway-controller
EOF

# 5. Create Gateway shared-gw in gw-multi-ns (task 7 pre-existing)
cat <<'EOF' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gw
  namespace: gw-multi-ns
spec:
  gatewayClassName: nginx-gw
  listeners:
  - name: http
    protocol: HTTP
    port: 80
EOF

# 6. Create broken extra-etcd static pod (task 3)
mkdir -p /var/lib/etcd-extra
cat <<'STATICEOF' > /etc/kubernetes/manifests/extra-etcd.yaml
apiVersion: v1
kind: Pod
metadata:
  name: extra-etcd
  namespace: kube-system
  labels:
    component: extra-etcd
spec:
  containers:
  - name: extra-etcd
    image: registry.k8s.io/etcd:3.5.12-0
    command:
    - etcd
    - --name=extra-etcd
    - --data-dir=/var/lib/etcd-extra-wrong
    - --listen-client-urls=https://127.0.0.1:2399
    - --advertise-client-urls=https://127.0.0.1:2399
    - --listen-peer-urls=https://127.0.0.1:2381
    - --initial-advertise-peer-urls=https://127.0.0.1:2382
    - --initial-cluster=extra-etcd=https://127.0.0.1:2382
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --client-cert-auth=true
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --peer-client-cert-auth=true
    volumeMounts:
    - mountPath: /var/lib/etcd-extra
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /var/lib/etcd-extra
      type: DirectoryOrCreate
    name: etcd-data
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
STATICEOF

# 7. Create artifact directories on master
mkdir -p /var/work/tests/artifacts/{3,14,15}
chmod 777 -R /var/work/tests/artifacts

# 8. Break containerd on worker node_2 (task 9) — disable CRI plugin
sleep 60
WORKER2=$(kubectl get nodes -l work_type=infra_core -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || true)
if [[ -n "$WORKER2" ]]; then
  ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER2} \
    "sudo sed -i '1i disabled_plugins = [\"cri\"]' /etc/containerd/config.toml && sudo systemctl restart containerd && sudo systemctl restart kubelet" || true
fi

# 9. Break kubelet CA path on worker node_3 (task 20)
sleep 30
WORKER3=$(kubectl get nodes -l work_type=infra_core -o jsonpath='{.items[1].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || true)
if [[ -n "$WORKER3" ]]; then
  ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@${WORKER3} \
    "sudo sed -i 's|clientCAFile:.*|clientCAFile: /etc/kubernetes/pki/ca-wrong.crt|' /var/lib/kubelet/config.yaml && sudo systemctl restart kubelet" || true
fi
