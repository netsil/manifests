#!/bin/bash
set -e

#
# Script to automate AOC installation on a Kubernetes cluster
#
# Pre-requisites:
# 1. In order to install AOC server, atleast one node in the k8s cluster should have minimum 4 CPU and 16 GB RAM
# 2. kubectl should point to the cluster
#

cleanup(){
	clear;
    
    echo "=========== Cluster Information =================";
    kubectl cluster-info
    echo "PROMPT: Are you sure you want to remove AOC installation from this cluster [y/n][n]:"
    read choice;
    if [[ "${choice}" == "y" ]]; then
	    kubectl delete daemonset collector -n netsil
	    kubectl delete svc netsil -n netsil
	    kubectl delete deploy netsil -n netsil
	    kubectl delete ns netsil
	exit 0;
	fi
}

getNodeList(){
    NodeList=$(kubectl get nodes --output=jsonpath={.items..metadata.name})
}

checkdnsPolicy(){
	KUBE_SERVER_VERSION=$(kubectl version | grep Server | awk -F "," '{print $2}' | cut -d":" -f2 | tr -cd '[:alnum:]')
	if [[ ${KUBE_SERVER_VERSION} -lt 6 ]]; then
        DISPLAY_VERSION_WARNING="1"
	    dnsPolicy='Default'
	else
        DISPLAY_VERSION_WARNING="0"
	    dnsPolicy='ClusterFirstWithHostNet'
	fi
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
        RAM_count=${RAM_count%??}
        if [[ "$PRINT" != "" ]]; then
            echo "${node}      ${CPU_count} CPU(s)     $(( ${RAM_count} / 1024 )) MB";
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
	
	# Delete deployment if it exists already
    kubectl get deployment netsil --namespace netsil > /dev/null 2>&1 && kubectl delete deployment netsil --namespace netsil
    # Generate AOC Server deployment
    cat <<EOF>aoc-server-deployment.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: netsil
  name: netsil
spec:
  replicas: 1
  template:
    metadata:
      name: stream-processor
      labels:
        app: netsil
        component: netsil
        version: stable
    spec:
      containers:
      - name: netsil
        image: netsil/netsil:stable-1.6.1
        command:
        - /root/startup.sh
        ports:
        - containerPort: 80
        - containerPort: 443
        - containerPort: 2000
        - containerPort: 2001
        - containerPort: 2003
        - containerPort: 2003
          protocol: UDP
        volumeMounts:
        - name: alerts
          mountPath: /var/lib/netsil/alerts/data
        - name: ceph-conf
          mountPath: /etc/ceph
        - name: ceph-data
          mountPath: /var/lib/ceph-data
        - name: druid-index-cache
          mountPath: /var/tmp/druid/indexCache
        - name: druid-realtime-segments
          mountPath: /var/lib/netsil/druid/realtime-segments
        - name: elasticsearch
          mountPath: /usr/share/elasticsearch/data
        - name: kafka-logs
          mountPath: /var/lib/netsil/kafka/kafka-log-dir
        - name: licenses
          mountPath: /var/lib/netsil/lite/license-manager/licenses
        - name: mysql
          mountPath: /var/lib/mysql
        - name: redis
          mountPath: /var/lib/redis
        - name: user-persistence
          mountPath: /var/lib/netsil/user-persistence/data
        - name: zookeeper
          mountPath: /var/lib/netsil/zookeeper/data
      volumes:
      - name: alerts
        hostPath:
          path: /var/lib/netsil/lite/alerts/data
      - name: ceph-conf
        hostPath:
          path: /var/lib/netsil/lite/ceph/conf
      - name: ceph-data
        hostPath:
          path: /var/lib/netsil/lite/ceph/data
      - name: druid-index-cache
        hostPath:
          path: /var/tmp/druid/indexCache
      - name: druid-realtime-segments
        hostPath:
          path: /var/lib/netsil/lite/druid/realtime-segments
      - name: elasticsearch
        hostPath:
          path: /var/lib/netsil/lite/elasticsearch/data
      - name: licenses
        hostPath:
          path: /var/lib/netsil/lite/license-manager/licenses
      - name: kafka-logs
        hostPath:
          path: /var/lib/netsil/lite/kafka/kafka-log-dir
      - name: mysql
        hostPath:
          path: /var/lib/netsil/lite/mysql/data
      - name: redis
        hostPath:
          path: /var/lib/netsil/lite/redis
      - name: user-persistence
        hostPath:
          path: /var/lib/netsil/lite/user-persistence/data
      - name: zookeeper
        hostPath:
          path: /var/lib/netsil/lite/zookeeper/data
      nodeSelector:
        kubernetes.io/hostname: ${AOC_Server}
EOF
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
    cat <<EOF>netsil-svc.yaml
apiVersion: v1
kind: Service
metadata:
  namespace: netsil
  name: netsil
spec:
  selector:
    app: netsil
    component: netsil
  ports:
    - name: http
      port: 80
      nodePort: 31000
    - name: https
      port: 443
      nodePort: 30443
    - name: port2000
      port: 2000
    - name: port2001
      port: 2001
    - name: port2003
      port: 2003
    - name: port2003udp
      port: 2003
      protocol: UDP
  type: NodePort
EOF
    kubectl get svc netsil --namespace netsil > /dev/null 2>&1 || kubectl create -f netsil-svc.yaml
    if [[ "${SERVICE_TYPE}" == "LoadBalancer" ]]; then
        # Generate LB service file
        cat <<EOF>netsil-svc-lb.yaml
apiVersion: v1
kind: Service
metadata:
  namespace: netsil
  name: netsil-lb
spec:
  selector:
    app: netsil
    component: netsil
  ports:
    - name: http
      port: 80
  type: LoadBalancer
EOF
        kubectl create -f netsil-svc-lb.yaml
    fi
}

installAOCCollectors()
{
    echo "INFO : Installing netsil collectors via DaemonSet"
    cat <<EOF>aoc-collectors-daemonset.yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  namespace: netsil
  name: collector
  labels:
    app: netsil
    component: collector
spec:
EOF
if [[ "${dnsPolicy}" == "ClusterFirstWithHostNet" ]]; then
cat <<EOF>>aoc-collectors-daemonset.yaml
  minReadySeconds: 0
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
EOF
fi
cat <<EOF>>aoc-collectors-daemonset.yaml
  template:
    metadata:
      labels:
        app: netsil
        component: collector
    spec:
      hostNetwork: true
      dnsPolicy: ${dnsPolicy}
      containers:
      - name: collector
        image: netsil/collectors:stable-1.6.1
        command: ["/bin/bash","-c","while true ; do NETSIL_SP_HOST=\$NETSIL_SERVICE_HOST /opt/netsil/collectors/start.sh ; echo Exiting, possibly to upgrade ; sleep 5 ; done"]
        securityContext:
          capabilities:
            add:
            - NET_RAW
            - NET_ADMIN
        env:
        - name: DEPLOY_ENV
          value: 'docker'
        - name: SAMPLINGRATE
          value: '100'
        - name: KUBERNETES
          value: "yes"
        - name: SD_BACKEND
          value: docker
        volumeMounts:
        - name: cgroup
          mountPath: /host/sys/fs/cgroup/
          readOnly: true
        - name: proc
          mountPath: /host/proc/
          readOnly: true
        - name: docker-sock
          mountPath: /var/run/docker.sock
          readOnly: true
      volumes:
      - name: cgroup
        hostPath:
          path: /sys/fs/cgroup/
      - name: proc
        hostPath:
          path: /proc/
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
EOF
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

    if [[ "${DISPLAY_VERSION_WARNING}" == "1" ]] ; then
        echo "==========================================================================";
        echo 'Warning: Unable to set dnsPolicy to ClusterFirstWithHostNet because your kubernetes server version is too low.'
        echo 'Certain service integrations may be unavailable in the AOC because of this.'
        echo 'As a workaround, you may redeploy your collectors with the variables: '
        echo 'OVERWRITE_RESOLVCONF="yes" and K8S_NAMESERVER="<address-of-kube-dns-service>"'
    fi

	
	echo "==========================================================================";
	echo "Netsil AOC and collectors are installed now.";
	if [[ "${SERVICE_TYPE}" == "LoadBalancer" ]]; then
	    echo "INFO : AOC server is available on Load Balancer IP $LB_IP";
	else
	    node_ips=$(kubectl get nodes --output=jsonpath={.items..status.addresses[1].address})
	    echo "INFO : Node IPs ${node_ips}";
	    echo "INFO : AOC server is avaialble on Port 31000 [HTTP] and Port 30443 [HTTPS] of above IPs";
	    echo "INFO : Please ensure this port is open in firewall";
	fi

	echo "==========================================================================";
	
}

main(){
    clear;
    
    echo "=========== Cluster Information =================";
    kubectl cluster-info
    echo "PRE-REQS :";
    echo "AOC server needs at least one node with min 4 CPU and 15GB RAM";
    echo "ALL nodes need internet connectivity to pull images from Docker Hub"
    echo "PROMPT : Please confirm that you want to install AOC on above cluster (y/n)[y]:";
    read choice;
    if [[ "${choice}" != "y" ]] && [[ "${choice}" != "" ]] ; then
         exit 1;
    fi
    
    #
    # Handling Service type by prompting user
    #
    echo "=============================================================";
    echo "INFO : This automation does not support ingress controller.";
    echo "PROMPT : Default Service type is NodePort. Type yes if you want a LoadBalancer instead (y/n)[n]:";
    read choice;
    if [[ "${choice}" == "y" ]]; then
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
    checkdnsPolicy
    installAOCCollectors
    displayInfo
}

if [[ "$1" == "delete" ]]; then
    cleanup
fi
main



