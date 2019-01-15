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
Before users can access the Kubernetes cluster API, an operator must apply a RBAC policy to grant them access.  
Reference: https://kubernetes.io/docs/reference/access-authn-authz/rbac/

To help get started, here is an example:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
  name: developer2-ldaptest-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: developer2
  ```
In this RBAC policy, are going to create a RBAC policy called developer2-ldaptest-admin.  It will use a Kubernetes default clusterrole, called admin, to give developer2 administrative privileges in a particular namespace.

Create the namespace  
`$ kubectl create ns <namespace name>`  
Save the RBAC to a .yml file and apply it to the namespace  
`$ kubectl apply –f <filename> –n <namespace name>`  

Additionally, you can view the other clusterroles with the command  
`$ kubectl get clusterroles`

#### Step 5: Retrieve User Token
Different from Operators, Developers will retrieve their tokens and populate their kubeconfig by running a script from their workstation.
Today, the scripts are written for Linux and Windows.  
Linux - https://raw.githubusercontent.com/csaroka/pks/master/tokenrefresh/get-pks-k8s-config.sh  
Windows - https://raw.githubusercontent.com/csaroka/pks/master/tokenrefresh/get-pks-k8s-config.ps1

##### Retrieve Developer Token – Linux User
a. Open a text-editor and paste from https://raw.githubusercontent.com/csaroka/pks/master/tokenrefresh/get-pks-k8s-config.sh   
b. Save as `<filename>.sh`  
c. Make the file executable with  
`$ chmod a+x <filename>.sh`  
d. Run the file `$ ./<filename>.sh`  
e. Answer Prompts:  
`API: <FQDN>`  
`CLUSTER: <FQDN>`  
`USER: <LDAP User Name>`  
`Password: <LDAP User Password>`  
f. Run `$ kubectl get pods` to verify cluster access
##### Retrieve Developer Token – Winidows User
a. Install Powershell Core 6.1 or later  https://github.com/PowerShell/PowerShell/releases  
b. Install OpenSSL Win64 v1.1.1 or later for Windows https://slproweb.com/products/Win32OpenSSL.html  
c. Add to System variables, path
`C:\Program Files\OpenSSL-Win64\bin`  
d. Download and install kubectl from Pivotal Network
https://network.pivotal.io/products/pivotal-container-service#/releases/191865/file_groups/1134  
e. Add the location of `kubectl` to path or from within the same directory, open a text-editor and paste from https://raw.githubusercontent.com/csaroka/pks/master/tokenrefresh/get-pks-k8s-config.ps1 
f. Save as `<filename>.ps1`  
g. Open PowerShell 6 and navigate to the directory containing the .ps1 script  
h. Execute the script with `.\<filename>.ps1`  
i. Answer Prompts:  
`API: <FQDN>`  
`CLUSTER: <FQDN>`  
`USER: <LDAP User Name>`  
`Password: <LDAP User Password>`  
j. Run `$ kubectl get pods` to verify cluster access

#### Accessing the Kubernetes Dashboard

Open a terminal window and run the command
`$ kubectl proxy`

Open and browser windows and navigate to:  
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

Either import the user kube .config file or paste the user token  
##### Import kube.config file  
a. For Linux and MacOS, the kube .config file is often found in ~/.kube/.config  
b. For Windows, the kube config file is often found in  `C:\Users\<username>\.kube\config`  
##### Copy and paste the user refresh token  
a.  Run the command `$ kubectl config view`  
b. Identify the appropriate context, user, and refresh token  
c. Copy the refresh token and paste into the UI prompt

### Scaling Out Kubernetes Clusters
#### Increase the number of worker nodes

Use the PKS CLI to log in  
`$ pks –a <pks api fqdn> –u <ldap username> –k`  
List the existing Kubernetes clusters  
`$ pks clusters`  
Get the current number of Kubernetes cluster worker nodes  
`$ pks cluster <cluster name>`  
Resize the cluster  
`$ pks resize <cluster name> -n <new total # of nodes>`  
Note: For instance, to increase the number of worker nodes from 3 to 5, enter 5, not 2, for the number of nodes.

### Destryoing a Kubernetes Cluster
Use the PKS CLI to log in  
`$ pks –a <pks api fqdn> –u <ldap username> –k`  
List the existing Kubernetes clusters  
`$ pks clusters`  
Destroy the Kubernetes cluster  
`$ pks delete-cluster <cluster name>`

## Working with the Harbor Registry
For secure registry access, users will require the registry root certificate.  To obtain the root certificate, a registry admin needs to log into the Harbor management portal and navigate to Administration > Configuration > System Settings. Next, select the hyeperlink to Download the Registry Root Certificate. Then, the admin user can save and share the root certificate with the registry users.

#### Docker Client Login - Linux User
`$ sudo mkdir -p /etc/docker/certs.d/<Harbor FQDN>`  
`$ sudo cp ca.crt /etc/docker/certs.d/<Harbor FQDN>`  
`$ mkdir -p ~/.docker/tls/<Harbor FQDN>\:4443/`  
`$ cp ca.crt ~/.docker/tls/<Harbor FQDN>\:4443/`  
`$ sudo cp ca.crt /usr/local/share/ca-certificates/`  
`$ sudo update-ca-certificates`  
`$ service docker restart`  
`$ docker login <Harbor FQDN>`

#### Docker Client Login - Windows User  
Download the Harbor root certificate to the client workstation.  
From the Windows UI, open the certificate file and import to local machine.  
Restart the docker client service  
Open the CMD window, and run  
`$ docker login <Harbor FQDN>`  
For additional support, see the Harbor User Guide, https://github.com/goharbor/harbor/blob/master/docs/user_guide.md#pull-image-from-harbor-in-kubernetes, 
or Public Docker Documentation for Guidance. We will eventually add the process to this document



#### Docker Client Login - Mac User
Download and import the Harbor root certificate to the client workstation.  
See the Linux instructions.  

For additional support, see the Harbor User Guide, https://github.com/goharbor/harbor/blob/master/docs/user_guide.md#pull-image-from-harbor-in-kubernetes, 
or Public Docker Documentation for Guidance. We will eventually add the process to this document


#### (Alternative) Insecure Registry Access 
Create or Modify daemon.json   
`$ vim /etc/docker/daemon.json`
```
{
   "insecure-registries" : [ "harbor.corp.local" ]
}
```
Then, restart the docker service

### Pushing a image to Harbor  
Locally load, build, or pull an image from an external source  

Login to the Harbor Registry from the command-line  
`$ docker login <harbor fqdn>`  
Tag the image:  
`$ docker tag <image name> <habor fqdn>/<repository>/<image name>:<version>`  
Push the image:  
`$ docker push <habor fqdn>/<repository>/<image name>:<version>`

### Kubernetes App Deployments with Harbor Images

#### Public Repository  
Add Harbor image path to Kubernetes deployment specification  
`image: <Harbor FQDN>/<Repository>/<Image Name>:<Version>`
#### Private Repository
Create a Kubernetes secret
```
$kubectl create secret docker-registry regsecret \
–-docker-server=http://<Harbor FQDN>:4443 \
--docker-username=<username> \
--docker-password=<password> --docker-email=<email address>
```
Add Harbor image path to Kubernetes deployment specification  
`image: <Harbor FQDN>/<Repository>/<Image Name>:<Version>`

## Common Tasks and Integrations

### Switch Kubernetes Contexts/Clusters and Set Namespace  
View kubeconfig content  
`$ kubectl config view`  
View kubectl contexts and current context  
`$ kubectl config get-contexts `  
OR just current  
`$ kubectl config current-context`  
Switch context  
`$ kubectl config use-context <context name>`  
Switch Namespace  
`$ kubectl get ns`  
Identify Namespace and switch  
`$ kubectl config set-context <context name> --namespace=<namespace name>`

### Define a default Storage Class in Kubernetes

Many app deployments, specifically Helm Charts, expect a defined default storage class. Operators can manually create the default storage class following creation of the Kubernetes cluster, or automatically by injecting the Kubernetes specification in the PKS plan’s post-installation task field. 

As an operator, verify current context
`$ kubectl config get-contexts `
Save the storage class specification to a .yml file. For example,
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: thin
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/vsphere-volume
parameters:
    diskformat: thin
```
apply it to the cluster
`$ kubectl apply –f <filename>`

To set an existing storage class as default, list the current storageclasses in the cluster:

`$ kubectl patch storageclass <your-class-name> \
-p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`

### Kubernetes Add-ons

#### Configuring Tiller
https://docs.pivotal.io/runtimes/pks/1-2/configure-tiller-helm.html


#### Jenkins-X on PKS Kubernetes
##### Preparations
Requires RBAC, Default Storage Class, and Helm
1. Verify cluster deployed with privileged containers – See PKS Plan in Ops Manager
2. Create a default storage class the cluster
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: thin
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/vsphere-volume
parameters:
    diskformat: thin
```
3. Get jx: https://jenkins-x.io/getting-started/install/


##### Installation
1. Run   
`$ jx install`  
2. Select `pks`
3. Enter `Yes` for ingress controller
4. Enter domain `<domain name>`
5. Get new Jenkins virtual server IP from NSX Manager and create an A-record with wildcard in DNS: *.jx.corp.lopcal
6. Enter GitHub user account and API token
https://github.com/settings/tokens/new?scopes=repo,read:user,user:email,write:repo_hook
7. During deployment, you need to correct the MongoDB image IPV6 variable and image  
`$ kubectl edit deployment jenkins-x-mongodb -n jx
Add name and value to list of ENV variables and update image`  
```
name: MONGODB_ENABLE_IPV6
value: “no”
image: docker.io/bitnami/mongodb:4.0.3-debian-9-r26
```
8. Enter `<esc>:wq` to save and exit the VI editor
9. For up to 10 minutes, monitor mongodb and monocular-api pods, ensuring that that both stabilize and enter RUNNING status  
`$ watch kubectl get pods –n jx`  
Follow output guidance from jx install console

### Visibility into PKS-deployed Kubernetes Clusters
#### OSS Prometheus and Grafana

https://code.vmware.com/samples/4224/visibility-into-pks-deployed-kubernetes-clusters-with-oss-prometheus-and-grafana-

View on GitHub: https://github.com/csaroka/kubernetes-monitoring

### NFS Server Provisioner with RWX PVC Support
#### Persistent Storage for Scaling Web Front-Ends
https://code.vmware.com/samples/4552/nfs-server-provisioner-with-rwx-pvc-support-for-scaling-web-front-ends







