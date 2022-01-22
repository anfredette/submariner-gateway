#!/bin/sh

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: test-vm
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Endpoints
metadata:
  name: test-vm
subsets:
  - addresses:
      - ip: 192.168.122.142
    ports:
      - port: 80
EOF

subctl export service -n default test-vm

sleep 2s

echo "Check global ingress IP for test-vm"

kubectl get globalingressip test-vm

