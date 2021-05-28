#!/bin/bash

clear
echo "What kind of environment?"
PS3="Enter option: "
select option in "VirtualBox" "AWS" 
do  
    case $option in
    "VirtualBox")
        ENVIRONMENT=1
        break ;;
    "AWS")
        ENVIRONMENT=2
        break;;
    *)
        clear
        echo "Sorry, wrong selection";;
    esac
done

if [ $ENVIRONMENT -eq 1 ]
then
    cp /dev/null ansible/group_vars/all.yml
    echo "Generate ssh keys"
    if [ ! -d vagrant/keys ]
    then   
        mkdir vagrant/keys 
    fi
    ssh-keygen -N '' -q -f vagrant/keys/key
    echo "Init Kubernetes Cluster Menu"
    sleep 1
    bash vagrant/scripts/menu.sh 
    echo "Create Linux VM"
    cd vagrant
    vagrant up
    echo "Initiate provisioning with Ansible"
    cd ..
    docker-compose -f docker/docker-compose.yml run --rm ansible ansible-playbook -i inventory.yml playbook.yml
    echo "Connecting to Kubernetes Cluster"
    if [ ! -d kubernetes/kubectl]
    then 
        mkdir kubernetes/kubectl
    fi
    ssh-keygen -f "/home/aiwass/.ssh/known_hosts" -R "192.168.33.10"
    scp -i vagrant/keys/key vagrant@192.168.33.10:/home/vagrant/.kube/config kubernetes/kubectl
    docker-compose -f docker/docker-compose.yml run --rm kubectl sh
elif [ $ENVIRONMENT -eq 2 ]
then
    echo "---
ansible_user: centos
ansible_ssh_private_key_file: ../terraform/keys/key" > ansible/group_vars/all.yml
    echo "Generate ssh keys"
    if [ ! -d terraform/keys ]
    then   
        mkdir terraform/keys 
    fi
    ssh-keygen -N '' -q -f terraform/keys/key
    sleep 1
    bash terraform/scripts/menu.sh
    echo "Create AWS environment"
    docker-compose -f docker/docker-compose.yml run --rm terraform apply -auto-approve
    sleep 1
    echo "Retrieve Load Balancer IP addresses"
    ELB=$(cat terraform/load_balancer.tf | head -n 1 | awk '{print $1}')
    if test $ELB 
    then
        CONTROLPLANE_IP=$(docker-compose -f docker/docker-compose.yml run --rm terraform output nlb)
        echo "---
# vars file for kubeadm-init
controlplane_ha: '--control-plane-endpoint=$CONTROLPLANE_IP'
controlplane_ip: $CONTROLPLANE_IP" > ansible/kubeadm-init/vars/main.yml
    fi
    echo "Initiate provisioning with Ansible"
    docker-compose -f docker/docker-compose.yml run --rm ansible ansible-playbook -i aws_ec2.yml playbook.yml 
    if test $ELB 
    then 
        echo "Connecting to Kubernetes Cluster"
        ssh -l vagrant -i keys/key $SSH_IP 
    fi
fi
