#!/bin/bash

CURRENT_DIR=$(pwd)

GATEWAY_ENDPOINT_DEVICE=enp0s3
CLUSTER_A_IP=192.168.122.26
CLUSTER_B_IP=192.168.122.27
EXTERNAL_VM_IP=192.168.122.142
CLUSTER_CIDR=10.42.0.0/24
EXTERNAL_CIDR=192.168.122.0/24
EXTERNAL_SERVICE_NAME=test-vm
EXTERNAL_SERVICE_CLUSTER=cluster-a

USER=axon

export CLUSTER_NAME=$(hostname)
if [ $CLUSTER_NAME == "cluster-a" ]; then
    export IP=$CLUSTER_A_IP
elif [ $CLUSTER_NAME == "cluster-b" ]; then
    export IP=$CLUSTER_B_IP
fi

CABLE_DRIVER=--cable-driver=vxlan
#CABLE_DRIVER=--cable-driver=libreswan
#NATTPORT=--nattport=4600

# To use the airgap install, set the following to "true"
# See https://rancher.com/docs/k3s/latest/en/installation/airgap/ for details
export INSTALL_K3S_SKIP_DOWNLOAD=false

