#!/bin/bash
echo " *** worker node  mock-6  k8s-2"
# Break kubelet config path for task 1
sed -i 's|/var/lib/kubelet/config.yaml|/var/lib/kubelet/config-broken.yaml|g' \
  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet || true
