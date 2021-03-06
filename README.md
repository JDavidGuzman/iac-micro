# Infrastructure as Code

This repository contains an executable file named start.sh, which will prompt a menu in order to show the options to select the infrastructure for the Kubernetes cluster. There are basically two environments, one for Virtual Box managed by vagrant; and another one for AWS Cloud managed by terraform. The Kubernetes Cluster in both cases will be set up with ansible using kubeadm admin tool, and the options for OS are between Centos 7 and Ubuntu Xenial. Docker is required in order to start the ansible container included in this code. Ansible will automatically install the CNI plugin from the Calico Project from any of the selected environments

## Virtual Box

As stated before, in order to run the Virtual Box option; vagrant is required.

Minimum two virtual machines will be required; one for a Master node and another one for a Worker node. There is the possibility to run a highly available cluster with multiple Master nodes; but this requires at least three master nodes for the control plane besides the selected number of worker nodes; this in order to achieve a fault tolerance of at least one master node due to the Quorum needed on the RAFT protocol used by Kubernetes for leader election; thus an Nginx with a layer 4 load balancer configuration will be initiated on a docker container. This feature was enabled just for recreational purposes, in its place I recommend running just one master and one worker. If a local setup of a multi-node control plane is really needed, I would recommend using [KinD](https://kind.sigs.k8s.io/); a lighter implementation without virtual machines that means Kubernetes in Docker.

## AWS

This option will set up a Kubernetes cluster on AWS infrastructure using t3.small EC2 instances as nodes, which fulfill the minimum requirements established by Kubernetes documentation. Each node will be located on the control plane group or on the worker's groups and depending on the number of nodes on each group it will run on a different Availability Zone. The option to chose among one or three master nodes is available, if the last is selected it will deploy a Network Load Balancer that will serve as a control plane endpoint in order to facilitate leader election; wich will listen on port 6443 for kube-apiserver and on port 22 for ssh. In the same way; a Security Group for worker nodes is configured in order to allow communication on port 30000 to 32767 for Nodeport service feature on Kubernetes. For simplicity, the AMI used will be Centos 7 published by Amazon.

