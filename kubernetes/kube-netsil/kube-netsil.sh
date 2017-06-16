#!/bin/bash

set -e

#
# Script to automate AOC installation on a Kubernetes cluster
#
# Pre-requisites:
# 1. In order to install AOC server, atleast one node in the k8s cluster should have minimum 4 CPU and 16 GB RAM
# 2. kubectl should point to the cluster
#

getNodeList(){
    NodeList=$(kubectl get nodes --output=jsonpath={.items..metadata.name})
}

checkCPURAM(){
	
    PRINT=${1}
    getNodeList
    n=0
    for node in $NodeList
    do
        CPU_count=$(kubectl get nodes --output=jsonpath={.items[${n}].status.allocatable.cpu})
        RAM_count=$(kubectl get nodes --output=jsonpath={.items[${n}].status.allocatable.memory})
        # Removing the Ki in RAM count
        RAM_count=${RAM_count::-2}
        if [[ "$PRINT" != "" ]]; then
            echo "${node}      ${CPU_count}      ${RAM_count}";
        fi
        if [[ ${CPU_count} -gt 3 && ${RAM_count} -gt 15000000 ]]; then
            AOC_Server=${node}
            echo "INFO : AOC server will be installed on node $AOC_Server";
            break;
        fi
        n=$(( $n + 1 ))
    done
}

checkns(){
#
# Check for netsil namespace
# Create namespace if it does not exist
#
     nslist=$(kubectl get ns --output=jsonpath={.items..metadata.name})
     for ns in $nslist
     do
         if [[ "$ns" == "netsil" ]]; then
             ns_found=True;
         fi
     done
     if [[ "${ns_found}" != "True" ]]; then
         kubectl create ns netsil
     fi
}

installAOCServer(){
	
	cp -f aoc-server-deployment.yaml.tpl aoc-server-deployment.yaml;
	

    sed -i "s|#AOC_SERVER#|${AOC_Server}|g" aoc-server-deployment.yaml
    # Delete deployment if it exists already
    kubectl get deployment netsil --namespace netsil > /dev/null 2>&1 && kubectl delete deployment netsil --namespace netsil
    
    kubectl create -f aoc-server-deployment.yaml
    #
    # Check if AOC server is UP
    #
    n=1;
    while true
    do
        echo "INFO : Checking if netsil server is UP (Attempt $n). Recommended wait 10 attempts";
        if [[ $(kubectl get deployment netsil -n netsil --output=jsonpath={.status.availableReplicas}) -eq 1 ]]; then
            server_running=true
            break
        else
            echo "INFO : Netsil server is not up yet. Sleeping 30 seconds. Press Ctrl + C to stop the loop.";
            sleep 30;
        fi
        n=$(( $n + 1 ));
    done
    if [[ "${server_running}" != "true" ]]; then
        echo "ERROR : Unable to start netsil server pod. Please check logs using: kubectl get pods -n netsil";
        exit 1;
    fi
    # Install a service to expose AOC
    echo "INFO : Creating netsil service if it does not exist already";
    kubectl get svc netsil --namespace netsil > /dev/null 2>&1 || kubectl create -f netsil-svc.yaml
    if [[ "${SERVICE_TYPE}" == "LoadBalancer" ]]; then
        kubectl create -f netsil-svc-lb.yaml
    fi
}

installAOCCollectors()
{
    echo "INFO : Installing netsil collectors via DaemonSet"
    kubectl get daemonset collector -n netsil > /dev/null 2>&1 || kubectl create -f aoc-collectors-daemonset.yaml
    for n in {1..5}
    do
    desired=$(kubectl get daemonset collector -n netsil --output=jsonpath={.status.desiredNumberScheduled})
    avail=$(kubectl get daemonset collector -n netsil --output=jsonpath={.status.numberAvailable})
    if [[ $desired -ne $avail ]]; then
        echo "INFO : Checking if all collectors are UP (Attempt $n of 5)";
        echo "INFO : Sleeping 10 seconds"
        sleep 10;
    else
        collector_running=true;
        break;
    fi
    done
    
    if [[ "${collector_running}" != "true" ]]; then
        echo "INFO : Collectors started successfully.";
    fi

}

displayInfo(){
	
	if [[ "${SERVICE_TYPE}" == "LoadBalancer" ]]; then
	     echo "INFO : Waiting for LB IP to be allocated.";
	     while [[ "${LB_IP}" == "" ]];
	     do
	     LB_IP=$(kubectl get svc netsil-lb -n netsil --output=jsonpath={.status.loadBalancer.ingress[0].ip});
	     echo "INFO : Sleeping 10 seconds to get LB IP.";
	     sleep 10;
	     done
	     
	fi
	
	echo "==========================================================================";
	echo "Netsil AOC and collectors are installed now.";
	if [[ "${SERVICE_TYPE}" == "LoadBalancer" ]]; then
	    echo "INFO : AOC server is available on Load Balancer IP $LB_IP";
	else
	    echo "INFO : AOC server is avaialble on Port 31000 of any node of this cluster";
	    echo "INFO : Please ensure this port is open in firewall";
	fi

	echo "==========================================================================";
	
}

main(){
	clear;
    echo "=========== Cluster Information =================";
    kubectl cluster-info
    echo "PRE-REQ : AOC server needs min 4 CPU and 15GB RAM.";
    echo "PRE-REQ : Your cluster needs at least one node matching above requirements";
    echo "PRE-REQ : ALL nodes need internet connectivity to pull images from Docker Hub"
    echo "PROMPT : Please confirm that you want to install AOC on above cluster (yes/no)[no]:";
    read choice;
    if [[ "${choice}" != "yes" ]]; then
         exit 1;
    fi
    
    #
    # Handling Service type by prompting user
    #
    echo "=============================================================";
    echo "INFO : This automation does not support ingress controller.";
    echo "PROMPT : Default Service type is NodePort. Type yes if you want a LoadBalancer instead (yes/no)[no]:";
    read choice;
    if [[ "${choice}" == "yes" ]]; then
        SERVICE_TYPE=LoadBalancer
    else
        SERVICE_TYPE=NodePort
    fi
    #
    # Start checking for resources
    echo "INFO : Checking for a node that meets server requirements."
    checkCPURAM
    if [[ "${AOC_Server}" == "" ]]; then
        echo "ERROR: Could not find a node which has at least 4 CPU and 15GB RAM. Below are Nodes with their CPU and RAM values:";
        checkCPURAM print
        exit 1
    fi
    checkns
    installAOCServer
	installAOCCollectors
	displayInfo
}

main



