# submariner-gateway
Submariner External Network POC

This repo contains scripts that implement the external network POC defined in https://submariner.io/getting-started/quickstart/external/.

Prerequisites
See https://submariner.io/getting-started/quickstart/external/

Summary
- Setup 3 VMs as described
- Install subctl
- Install yq
- Additionally, the scripts currently assume that KUBECONFIG is exported as follows:
  - `export KUBECONFIG=kubeconfig.cluster-a` (on cluster-a)
  - `export KUBECONFIG=kubeconfig.cluster-b` (on cluster-b)
    
The steps to install are as follows
1. Modify config.sh as required
2. Execute `deploy-cluster.sh` on cluster-a
3. Execute `deploy-cluster.sh` on cluster-b
4. Confirm that the clusters are connected by running `subctl show all`
The output should look something like the following:
```
cluster-a:~/submariner-gateway$ subctl show all
   Cluster "default"
   ✓ Showing Connections
   GATEWAY    CLUSTER    REMOTE IP       NAT  CABLE DRIVER  SUBNETS       STATUS     RTT avg.    
   cluster-b  cluster-b  192.168.122.27  no   vxlan         242.1.0.0/16  connected  993.264µs

✓ Showing Endpoints
CLUSTER ID                    ENDPOINT IP     PUBLIC IP       CABLE DRIVER        TYPE            
cluster-a                     192.168.122.26  xxx.xx.xxx.xx   vxlan               local           
cluster-b                     192.168.122.27  xxx.xx.xxx.xx   vxlan               remote

✓ Showing Gateways
NODE                            HA STATUS       SUMMARY                         
cluster-a                       active          All connections (1) are established

    Discovered network details via Submariner:
        Network plugin:  generic
        Service CIDRs:   [10.43.0.0/16]
        Cluster CIDRs:   [10.42.0.0/24,192.168.122.0/24]
        Global CIDR:     242.0.0.0/16
✓ Showing Network details

COMPONENT                       REPOSITORY                                            VERSION         
submariner                      quay.io/submariner                                    devel           
submariner-operator             quay.io/submariner                                    devel           
service-discovery               quay.io/submariner                                    devel           
✓ Showing versions
```
5. execute `create-dns.sh` on cluster-a to deploy a DNS server on cluster-a for non-cluster hosts
6. Setup test-vm as defined here: https://submariner.io/getting-started/quickstart/external/#set-up-non-cluster-hosts
7. execute `create-ext-svc.sh` on cluster-a to create Service, Endpoints, ServiceExport to access the test-vm from cluster pods
8. execute `create-nginx-svc.sh` on cluster-b to create a test nginx service
9. Run various connectivity tests defined in https://submariner.io/getting-started/quickstart/external/

NOTE: as of this commit on 1/23/2022, not all tests are running correctly.
