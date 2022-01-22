#!/bin/sh

# Create a list of upstream DNS servers as upstreamservers:
# Note that dnsip is the IP of DNS server for the test-vm, which is defined as nameserver in /etc/resolve.conf.
dnsip=10.0.3.3
lighthousednsip=$(kubectl get svc --kubeconfig kubeconfig.cluster-a -n submariner-operator submariner-lighthouse-coredns -o jsonpath='{.spec.clusterIP}')

cat << EOF > upstreamservers.txt
server=/svc.clusterset.local/$lighthousednsip
server=$dnsip
EOF

# Create configmap of the list
kubectl create configmap external-dnsmasq -n submariner-operator --from-file=upstreamservers.txt

# Use dns.yaml to create DNS server, and assign global ingress IP
# NOTE: dns.yaml file should have been created before running this script
kubectl apply -f dns.yaml
subctl export service -n submariner-operator external-dns-cluster-a

# Get global ingress IP:
echo ""
echo "Get global ingress IP for external-dns-cluster-a"
sleep 2s
kubectl --kubeconfig kubeconfig.cluster-a get globalingressip external-dns-cluster-a -n submariner-operator
