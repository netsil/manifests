## Pre-installation Instructions
Prerequisites
- Please check the [resource requirements](https://github.com/netsil/manifests#prerequisites)
- A running instance of Marathon, v1.1.1 or above

The installation instructions below use the dcos-cli, but you may use the the Marathon UI as well.

### Installation
* Install the AOC on Marathon
    
```
$ dcos marathon app add netsil-dcos.json
```

### Usage
After Netsil has started up, you can access the AOC from your web browser at `https://<dcos_address>/service/netsil`, where `<dcos_address>` is the address of your DC/OS cluster.
