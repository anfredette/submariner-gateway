#!/bin/bash
# BUG WORKAROUND: Manually create endpoint

. ./config.sh

SERVICE_NAME=$(kubectl get services -l submariner.io/exportedServiceRef=test-vm | grep submariner | awk '{print $1}')

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Endpoints
metadata:
  name: $SERVICE_NAME
subsets:
  - addresses:
      - ip: $EXTERNAL_VM_IP
    ports:
      - port: 80
EOF

