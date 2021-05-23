# Terraform to Kubeadm
This repository hosts the code that was demonstrated in this video https://youtu.be/F-ZJYjqr00Y
## The kubeadm config file
```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  extraArgs:
    cloud-provider: aws
clusterName: # PLACE YOUR CLUSTER NAME HERE 
controlPlaneEndpoint: # PLACE THE URL TO THE API LOAD BALANCER HERE
controllerManager:
  extraArgs:
    cloud-provider: aws
    configure-cloud-routes: "false"
kubernetesVersion: stable
networking:
  dnsDomain: cluster.local
  podSubnet: 192.168.0.0/16
  serviceSubnet: 10.96.0.0/12
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws
```
## The AMI image
For this setup to work you are expected to use an AMI that contains the following:
* Docker
* kuebctl
* kubeadm
* kubelet
The versions of the above software depends on the version of Kubernnetes that you intend to use. The code in this lab automatically selects the latest version of Kubernetes.
## How to use
Simply, run `terraform init` followed by `terraform plan` and  `terraform apply`. Notice that you will need a valid AWS account with administrative privileges (or at least is allowed to execute the actions in the Terraform code). Once the infrastructure is up and running, use the jump (bastion) server to login to the master node and execute `kubeadm init --config kubeadm.confg` where an example`kubeadm.config` file is listed above. The `kubeadm` command will print the necessary join command for other worker (or master) nodes. Copy and execute the command as necessary. The KUBECONFIG file is always created in `/etc/kubernetes/admin.conf`. You can use this file to create users and workflows.
