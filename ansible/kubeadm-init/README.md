Kubeadm-Init
=========

This role initialize a Kubernetes cluster using the kubeadm tool, as well as it will perform the installation of CNI from Calico Project. Depending on the infrastructure where this role is used, it would be able to setup a higly available Kubernetes cluster, executing the kubeadm join command for the nodes on the controlplane as well as in the worker nodes. 

Requirements
------------

Is required that Kubernetes components (kubectl, kubelet, kubeadm) where successfully intalled.

Role Variables
--------------

controlplane_ha: In case that this variable is needed, it will contain a command flag for kubeadm tool (--controlplane-endpoint) with its value in order to setup a endpoint in case that a load balancer is required of high availability purposes.
controlplane_ip: This will contain the ip for the control plane endpoint, wheter a master a node or a load balancer.
node_ip: This is used to specify the ip for the nodes, very useful for stating the private address on EC2 instances.

Dependencies
------------

This role depends on Kubernetes role

Author Information
------------------

David Guzmán