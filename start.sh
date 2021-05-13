#!/bin/bash

clear
echo "What kind of environment?"
PS3="Enter option: "
select option in "VirtualBox" "Cloud" 
do  
    case $option in
    "VirtualBox")
        ENVIRONMENT=1
        break ;;
    "Cloud")
        ENVIRONMENT=2
        clear
        echo "Sorry, not implemented yet";;
    *)
        clear
        echo "Sorry, wrong selection";;
    esac
done

if [ $ENVIRONMENT -eq 1 ]
then
    echo "Generate ssh keys"
    bash vagrant/scripts/create_keys.sh vagrant/keys
    echo "Init Kubernetes Cluster Menu"
    sleep 1
    bash vagrant/scripts/menu.sh vagrant
    echo "Create Linux VM"
    cd vagrant
    vagrant up
    echo "Initiate provisioning with Ansible"
    cd ..
    docker-compose -f docker/docker-compose.yml run --rm ansible_vagrant ansible-playbook -i inventory.yml playbook.yml
    echo "Connecting to Kubernetes Cluster"
    ssh -l vagrant -i vagrant/keys/key 192.168.33.10
fi
