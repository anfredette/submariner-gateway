#!/bin/sh
#Add routes on both cluster nodes:
sudo ip route add 8.8.8.8/32 dev enp0s3

#Deploy cluster-a on node-a
curl -sfL https://get.k3s.io | sh -

# Fixup kubeconfig
sudo cp /etc/rancher/k3s/k3s.yaml kubeconfig.cluster-a
sudo chown $(id -u):$(id -g) kubeconfig.cluster-a
IP=192.168.122.26
yq -i eval \
'.clusters[].cluster.server |= sub("127.0.0.1", env(IP)) | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
kubeconfig.cluster-a

#Use cluster-a as the Broker with Globalnet enabled
subctl deploy-broker --globalnet

# Label gateway node
kubectl label node cluster-a submariner.io/gateway=true

#Join cluster to the Broker
# Option 1:
subctl join broker-info.subm --clusterid cluster-a --natt=false --cable-driver vxlan

# Option 2:
# subctl join broker-info.subm --clusterid cluster-a --natt=false

# Option 3:
# CLUSTER_CIDR=10.42.0.0/24
# EXTERNAL_CIDR=192.168.122.0/24
# subctl join broker-info.subm --clusterid cluster-a --natt=false --clustercidr=${CLUSTER_CIDR},${EXTERNAL_CIDR} --cable-driver vxlan

#scp broker-info.subm from cluster-a to cluster-b
scp ./broker-info.subm axon@192.168.122.27:/home/axon/k3s

