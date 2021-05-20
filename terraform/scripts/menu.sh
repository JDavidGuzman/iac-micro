#!/bin/bash

function master_nodes {
    cp /dev/null terraform/terraform.tfvars
    if [ $1 -eq 1 ]
    then
        :
    fi
}

function worker_nodes {
    if [ $1 -eq 1 ]
    then
        :
    elif [ $1 -eq 2 ]
    then
        echo "worker_num = { a = 0, b = 1 }" >> terraform/terraform.tfvars
        if [ $2 -eq 1 ]
        then 
            echo "az         = { a = 0, b = 1 }" >> terraform/terraform.tfvars
        fi
    elif [ $1 -eq 3 ]
    then
        echo "worker_num = { a = 0, b = 1, c = 2 }" >> terraform/terraform.tfvars
        if [ "$2 -eq 1" ]
        then 
            echo "az         = { a = 0, b = 1, c = 2 }" >> terraform/terraform.tfvars
        fi
    fi
}

clear
echo "Number of Master Nodes?"
PS3="Enter option: "
select option in "One" 
do
    
    case $option in
    "One")
        MASTER=1
        master_nodes 1
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
        worker_nodes 1 $MASTER
        break ;;
    "Two")
        worker_nodes 2 $MASTER
        break ;;
    "Three")
        worker_nodes 3
        break ;;
    *)
        clear
        echo "Sorry, wrong selection";;
    esac
done