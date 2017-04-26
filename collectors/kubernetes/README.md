### Installation
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

