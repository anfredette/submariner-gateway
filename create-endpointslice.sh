#!/bin/bash
# WORKAROUND: Manually add endpointslice for external service

. ./config.sh

cat << EOF | kubectl apply -f -
addressType: IPv4
apiVersion: discovery.k8s.io/v1
endpoints:
- addresses:
  - $EXTERNAL_VM_IP
  conditions:
    ready: true
  deprecatedTopology:
    kubernetes.io/hostname: $EXTERNAL_SERVICE_CLUSTER
kind: EndpointSlice
metadata:
  labels:
    endpointslice.kubernetes.io/managed-by: lighthouse-agent.submariner.io
    lighthouse.submariner.io/sourceCluster: $EXTERNAL_SERVICE_CLUSTER
    lighthouse.submariner.io/sourceName: $EXTERNAL_SERVICE_NAME
    lighthouse.submariner.io/sourceNamespace: default
  managedFields:
  - apiVersion: discovery.k8s.io/v1beta1
    fieldsType: FieldsV1
    fieldsV1:
      f:addressType: {}
      f:endpoints: {}
      f:metadata:
        f:labels:
          .: {}
          f:endpointslice.kubernetes.io/managed-by: {}
          f:lighthouse.submariner.io/sourceCluster: {}
          f:lighthouse.submariner.io/sourceName: {}
          f:lighthouse.submariner.io/sourceNamespace: {}
      f:ports: {}
    manager: lighthouse-agent
    operation: Update
  name: $EXTERNAL_SERVICE_NAME-$EXTERNAL_SERVICE_CLUSTER
  namespace: default
ports:
- name: ""
  port: 80
  protocol: TCP
EOF
