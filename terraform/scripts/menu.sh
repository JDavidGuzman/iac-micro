#!/bin/bash

function master_nodes {
  cp /dev/null terraform/terraform.tfvars
  if [ $1 -eq 1 ]
  then
    cp /dev/null terraform/load_balancer.tf
    echo "---
# vars file for kubeadm-init" > ansible/kubeadm-init/vars/main.yml
    echo 'output "instance_ip" {
value = aws_instance.master["a"].public_ip 
}'  > terraform/outputs.tf
  elif [ $1 -eq 2 ]
  then 
    echo "master_num = { a = 0, b = 1, c = 2 }
az         = { a = 0, b = 1, c = 2 }" >> terraform/terraform.tfvars
    cp terraform/scripts/nlb.tf terraform/load_balancer.tf
    echo 'output "nlb" {
value = aws_lb.main.dns_name
}' > terraform/outputs.tf
  fi

}

function worker_nodes {
  if [ $1 -eq 1 ]
  then
      :
  elif [ $1 -eq 2 ]
  then
    echo "worker_num = { a = 0, b = 1 }" >> terraform/terraform.tfvars
    if test $2
    then 
      echo "az         = { a = 0, b = 1 }" >> terraform/terraform.tfvars
    fi
  elif [ $1 -eq 3 ]
  then
    echo "worker_num = { a = 0, b = 1, c = 2 }" >> terraform/terraform.tfvars
    if test $2
    then 
      echo "az         = { a = 0, b = 1, c = 2 }" >> terraform/terraform.tfvars
    fi
  fi
}

clear
echo "Number of Master Nodes?"
PS3="Enter option: "
select option in "One" "Three"
do
  case $option in
  "One")
      MASTER=1 
      master_nodes 1
      break ;;
  "Three")
      master_nodes 2
      break ;;
  *)
      clear
      echo "Sorry, wrong selection";;
  esac
done

clear
echo "Number of Worker Nodes?"
PS3="Enter option: "
select option in "One" "Two" "Three" 
do
  case $option in
  "One")
      worker_nodes 1 
      break ;;
  "Two")
      worker_nodes 2 $MASTER
      break ;;
  "Three")
      worker_nodes 3 $MASTER 
      break ;;
  *)
      clear
      echo "Sorry, wrong selection";;
  esac
done