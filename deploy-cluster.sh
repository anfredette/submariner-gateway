#!/bin/sh

. ./config.sh

# To identify the private-ip (used in the endpoint) of the node, submariner
# tries to identify the ip-address that would be used to reach 8.8.8.8 and uses
# that IP-address as the privateIP in the localEndpoint. If the interface used
# to reach 8.8.8.8 is not the same as the one intended to be the private gateway IP, Submariner will discover the wrong IP.
# The following is a hack to get Submariner to use the right interface when your test system has more than one.
# It may be commented out if the situation does not apply.
sudo ip route add 8.8.8.8/32 dev $GATEWAY_ENDPOINT_DEVICE

#Deploy k3s using default pod and service CIDRs
curl -sfL https://get.k3s.io | sh -

# Fixup kubeconfig
sudo cp /etc/rancher/k3s/k3s.yaml kubeconfig.$CLUSTER_NAME
sudo chown $(id -u):$(id -g) kubeconfig.$CLUSTER_NAME

yq -i eval \
'.clusters[].cluster.server |= sub("127.0.0.1", env(IP)) | .contexts[].name = env(CLUSTER_NAME)  | .current-context = env(CLUSTER_NAME)' \
kubeconfig.$CLUSTER_NAME

# Label this node as the gateway node
kubectl label node $(hostname) submariner.io/gateway=true

# Deploy Submariner
if [ $CLUSTER_NAME == "cluster-a" ]; then
    #Use cluster-a as the Broker with Globalnet enabled
    subctl deploy-broker --globalnet
    # Pass in external CIDR
    subctl join broker-info.subm --clusterid $CLUSTER_NAME --natt=false --clustercidr=${CLUSTER_CIDR},${EXTERNAL_CIDR} --cable-driver $CABLE_DRIVER
    #copy broker-info.subm and kubeconfig from cluster-a to cluster-b
    scp ./broker-info.subm $CLUSTER_USER@$CLUSTER_B_IP:$CURRENT_DIR
    scp ./kubeconfig.$CLUSTER_NAME $CLUSTER_USER@$CLUSTER_B_IP:$CURRENT_DIR
elif [ $CLUSTER_NAME == "cluster-b" ]; then
    subctl join broker-info.subm --clusterid $CLUSTER_NAME --natt=false --cable-driver $CABLE_DRIVER
    #copy broker-info.subm and kubeconfig from cluster-b to cluster-a
    scp ./kubeconfig.$CLUSTER_NAME $CLUSTER_USER@$CLUSTER_A_IP:$CURRENT_DIR
fi

