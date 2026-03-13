#!/bin/bash
echo " *** worker pc  cka mock-3  "

# Create artifact directories for tasks requiring file output
mkdir -p /var/work/tests/artifacts/{6,15,17}
mkdir -p /var/work/tests/result
chmod 777 -R /var/work/tests/artifacts

# Add ingress node IP to /etc/hosts for ingress testing
address=$(kubectl get no -l work_type=infra_core --context cluster1-admin@cluster1 -o json 2>/dev/null | jq -r '.items[0].status.addresses[] | select(.type == "InternalIP") | .address' 2>/dev/null || true)
if [[ -n "$address" ]]; then
  echo "$address app.k8s.local" >>/etc/hosts
fi
