## Pre-installation Instructions
Prerequisites
- Running kubernetes cluster
- Configured kubectl

If you wish to do so, you may install only the collectors on your main kubernetes cluster, and install Netsil AOC elsewhere.


### Installing Netsil AOC
* Create ```netsil``` namespace
```
$ kubectl create -f netsil-ns.yaml 
namespace "netsil" created
```

* Create ```netsil``` replication controller
```
$ kubectl create -f netsil-rc.yaml 
replicationcontroller "netsil" created
```

* Create ```netsil``` service.
    
At this point you might want to modify ```netsil-svc.yaml``` to change the type of service to ```LoadBalancer``` if you are using a cloud provider plugin that supports load balancers or create an ```Ingress``` if you have an Ingress Controller.

```
$ kubectl create -f netsil-svc.yaml 
(possible warning to open ports)
service "netsil" created

```


### Installing Collectors
* Create a ```netsil``` namespace.
    
If you installed Netsil AOC within kubernetes with the instructions above, you should have already done this and you can skip this step.
```
$ kubectl create -f netsil-ns.yaml 
namespace "netsil" created
```

* If you installed Netsil AOC outside of your kubernetes cluster, be sure to uncomment the settings below in `collector.yaml`. Then, enter the private IP address of your AOC instance where it says "AOC address here". Otherwise, you may skip this step.
```bash
#- name: NETSIL_SERVICE_HOST
#  value: '<AOC address here>'
```

* Create ```collector``` DaemonSet.
     
This will create a Netsil collector agent in every node of the cluster.
```
$ kubectl create -f collector.yaml
daemonset "collector" created
```


## Host Network and Flannel
If you are using Flannel as your network overlay it is possible you might run into the following issue: 

https://github.com/kubernetes/kubernetes/issues/20391

To work around this problem, you will want to run the following command on the host machines: 


iptables -t nat -I POSTROUTING -o flannel.1 -s *host-private-ip* -j MASQUERADE


## Google Container Engine
If you are using Google Container Engine to provision your Kubernetes cluster, you will need to modify the volume host paths in `netsil-rc.yaml` (and `netsil.yml`, if you are using that manifest file).

The **hostPath** mounts default to directories within `/opt/netsil`, but the `/opt` folder is read-only for clusters provisioned by Google Container Engine. Thus, you should modify the `/opt/netsil` **hostPath** mounts to a different path like `/var/lib/netsil`, for instance.


## Using Netsil
This section applies if you have installed Netsil AOC on your kubernetes cluster.

Unless you have modified the port settings in the service files above, these are the ports that should be opened to run Netsil:

Incoming UDP ports: 2003
Incoming TCP ports: 30443, 2001, 2003

All your external services will be monitored now using Netsil.

You can access Netsil by hitting your master public IP and appending *30443*. 
