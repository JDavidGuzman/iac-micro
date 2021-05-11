#!/bin/bash
#echo "Generate ssh keys"
#./keys/create_keys.sh keys
echo "Create Linux VM"
vagrant up
echo "Create nginx Load Balancer"
docker-compose -f ../ansible/docker-compose.yml run --rm -d --service-ports nginx_lb
echo "Initiate provisioning with Ansible"
docker-compose -f ../ansible/docker-compose.yml run --rm ansible ansible-playbook -i inventory.yml playbook.yml
