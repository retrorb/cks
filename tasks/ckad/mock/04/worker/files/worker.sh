#!/bin/bash
echo " *** worker pc mock-4  "
export KUBECONFIG=/root/.kube/config

mkdir -p /opt/logs/
chmod a+w /opt/logs/

# task 1 - Dockerfile for image build
mkdir -p /home/ubuntu/app
cat > /home/ubuntu/app/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Hello CKAD" > /app/message
CMD ["cat", "/app/message"]
EOF

# task 14 - CRD manifest
cat > /home/ubuntu/crd.yaml << 'EOF'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: foos.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              message:
                type: string
  scope: Namespaced
  names:
    plural: foos
    singular: foo
    kind: Foo
EOF

# task 20 - deprecated manifest (batch/v1beta1 CronJob removed in k8s 1.25)
mkdir -p /home/ubuntu
cat > /home/ubuntu/deprecated.yaml << 'EOF'
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: old-job
  namespace: deprecated-ns
spec:
  schedule: "*/10 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: old-job
            image: busybox
            command: ["echo", "hello"]
          restartPolicy: OnFailure
EOF

chown -R ubuntu:ubuntu /home/ubuntu/app/ /home/ubuntu/crd.yaml /home/ubuntu/deprecated.yaml
