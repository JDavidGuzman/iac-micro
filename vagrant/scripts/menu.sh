#!/bin/bash

function master_nodes {
    cp /dev/null vagrant/Vagrantfile
    echo 'Vagrant.configure("2") do |config|' >> vagrant/Vagrantfile
    echo >> vagrant/Vagrantfile
    if [ $1 -eq 1 ]
    then
    echo 'config.vm.define "master-0" do |master|
    master.vm.box = "placeholder"
    master.vm.hostname = "master-0"
    master.vm.network "private_network", ip: "192.168.33.10"
  end' >> vagrant/Vagrantfile
    echo "---
# vars file for kubeadm-init" > ansible/kubeadm-init/vars/main.yml
    elif [ $1 -eq 2 ]
    then
    echo '(0..2).each do |i|
    config.vm.define "master-#{i}" do |master|
      master.vm.box = "placeholder"
      master.vm.hostname = "master-#{i}"
      master.vm.network "private_network", ip: "192.168.33.1#{i}"
    end
  end' >> vagrant/Vagrantfile
    echo "---
# vars file for kubeadm-init
controlplane_ha: '--control-plane-endpoint=172.18.0.1'
controlplane_ip: 172.18.0.1" > ansible/kubeadm-init/vars/main.yml
    echo "Create nginx Load Balancer"
    docker-compose -f docker/docker-compose.yml run --rm -d --service-ports nginx_lb
    fi
}

function worker_nodes {
    echo >> vagrant/Vagrantfile
    if [ $1 -eq 1 ]
    then
    echo 'config.vm.define "worker-0" do |worker|
    worker.vm.box = "placeholder"
    worker.vm.hostname = "worker-0"
    worker.vm.network "private_network", ip: "192.168.33.20"
  end' >> vagrant/Vagrantfile
    elif [ $1 -eq 2 ] || [ $1 -eq 3 ]
    then
    echo "(0..$[$1-1]).each do |i|" >> vagrant/Vagrantfile
    echo 'config.vm.define "worker-#{i}" do |worker|
      worker.vm.box = "placeholder"
      worker.vm.hostname = "worker-#{i}"
      worker.vm.network "private_network", ip: "192.168.33.2#{i}"
    end
  end' >> vagrant/Vagrantfile
    fi

    echo >> vagrant/Vagrantfile
    echo 'config.vm.provider "virtualbox" do |vb|
    vb.memory = "2000"
    vb.cpus = 2
  end

  config.vm.provision "file", source: "../vagrant/keys/key.pub", destination: "$HOME/.ssh/authorized_keys"' >> vagrant/Vagrantfile

  echo "end" >> vagrant/Vagrantfile
}

function linux_distribution {
    sed -i "s/placeholder/$1/" vagrant/Vagrantfile
}


clear
echo "Number of Master Nodes?"
PS3="Enter option: "
select option in "One" "Three" 
do
    
    case $option in
    "One")
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
        worker_nodes 2
        break ;;
    "Three")
        worker_nodes 3
        break ;;
    *)
        clear
        echo "Sorry, wrong selection";;
    esac
done
clear

echo "OS Linux Distribution?"
PS3="Enter option: "
select option in "CentOS" "Ubuntu" 
do
    
    case $option in
    "CentOS")
        linux_distribution 'centos\/7'
        break ;;
    "Ubuntu")
        linux_distribution 'ubuntu\/xenial64'
        break ;;
    *)
        clear
        echo "Sorry, wrong selection";;
    esac
done
clear