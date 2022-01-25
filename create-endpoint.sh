#!/bin/bash
# BUG WORKAROUND: Manually create endpoint
# $1 is the submariner "internal-service-name" associated with test-vm service
# Example usage: create-endpoint.sh submariner-4cl54k5nvyvsg3p65n5la4lbtg5scllc

if [ -z "$1" ]
  then
    echo "The internal-service-name must be suplied as an argument"
    echo "Example: create-endpoint.sh submariner-4cl54k5nvyvsg3p65n5la4lbtg5scllc"
    exit
fi

. ./config.sh

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Endpoints
metadata:
  name: $1
subsets:
  - addresses:
      - ip: $EXTERNAL_VM_IP
    ports:
      - port: 80
EOF

