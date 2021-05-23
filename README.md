# Terraform to Kubeadm
This repository hosts the code that was demonstrated in this video
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