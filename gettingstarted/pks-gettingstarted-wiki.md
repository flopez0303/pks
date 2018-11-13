# VMware PKS PoC - Getting Started with the Platform
Version: 0.2  
Author: Charles Saroka

## Reference Locations
### PKS
VMware PKS on VMware Docs  
https://docs.vmware.com/en/VMware-Pivotal-Container-Service/index.html  
NSX-T Data Center on VMware Docs  
https://docs.vmware.com/en/VMware-NSX-T/index.html  
Harbor Registry User Guide on GitHub  
https://github.com/goharbor/harbor/blob/master/docs/user_guide.md  
Pivotal Ops Man on Pivotal Documentation  
https://docs.pivotal.io/pivotalcf/2-3/customizing/ops-man.html  
BOSH – Using the CLI  
https://bosh.io/docs/cli-v2/  
### Kubernetes
General Kubernetes  
https://kubernetes.io/docs/home/?path=users  
Helm  
https://docs.helm.sh/  
Project Hatchway  
https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/  
Docker  
https://docs.docker.com/  

## Common Tools for Interacting with VMware PKS and Kubernetes
Kubectl  
https://kubernetes.io/docs/tasks/tools/install-kubectl/  

Helm  
https://docs.helm.sh/using_helm/#installing-helm  
Note: Windows requires installation of Chocolatey https://chocolatey.org/install  

DockerCE  
https://store.docker.com/search?type=edition&offering=community  

PKS CLI (Operators Only)  
https://docs.pivotal.io/runtimes/pks/1-2/installing-pks-cli.html

#### Other Helpful Tools
kubectx and kubens  
https://github.com/ahmetb/kubectx  
dive  
https://github.com/wagoodman/dive

## Creating and Managing Kubernetes Clusters

### Create a Kubernetes Cluster Workflow
![alt text](https://github.com/csaroka/pks/blob/master/gettingstarted/images/create-cluster-flow.png "Create K8s Cluster Flow")

#### Step 1: Deploy the K8s Cluster
Use the PKS CLI to log in  
`$ pks –a <pks api fqdn> –u <ldap username> –k`    
List the existing plans (Managed in Ops Manager)  
`$ pks plans`  
List the existing network-profiles (Default = Small)  
`$ pks network-profiles`  
Create the cluster  
`$ pks create-cluster <cluster name> -e <external fqdn> -p <plan name>`

Optional add-ons:  
Override plan default number of worker nodes  `-n <#>`  
Creates medium load-balancer as opposed to a small load-balancer `--network-profile=<profile name>` Additional details https://docs.vmware.com/en/VMware-Pivotal-Container-Service/1.2/vmware-pks-12/GUID-PKS12-network-profiles.html

#### Step 2: Register the K8s Cluster in DNS
After creating the cluster, you need to register two entries in DNS  
##### Cluster Master API – API interface to the Kubernetes cluster
Following the creation of a Kubernetes cluster, the FQDN and IP are provided in the output of  
`$ pks cluster <cluster name>`  
Create an A-record in DNS mapping  output for Kubernetes Master Host -> Kubernetes Master IP
Ex. 10.96.65.74 -> k8s01api.corp.local
##### Ingress Controller – Layer 7 load-balancer for deployed applications
a. Record the cluster UUID from the above output  
b. Open a browser, enter the URL for NSX-T Manager, and login to the management portal  
c. Select Networking > Load-Balancers and select the load-balancer that matches the cluster’s UUID  
d. Identify the two virtual servers with a common IP for HTTP and HTTPS, and record the IP address  
e. Create an A-record in DNS mapping a wildcard FQDN to the IP address recorded in the previous step  
Ex. 10.96.65.75 -> *.k8s01apps.corp.local

#### Step 3: Retrieve Cluster Credentials (Operator Only)
Using the PKS CLI, run the following command to automatically populate your kubeconfig file  
Note: Only users with access to the PKS API via a role mapping can execute this command. Other users such as Developers use a separate method described later.  
`$ pks get-credentials <cluster name>`  
Using the kubectl CLI, you can view the new context and token  
`$ kubectl config view`  
Verify a connection to the Kubernetes cluster and the ability to view content from all namespaces  
`$ kubectl get all -–all-namespaces`

#### Step 4: Grant Developer/User Access with a Kubernetes RBAC Policy







