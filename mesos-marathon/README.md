## Pre-installation Instructions
Prerequisites
- A running instance of Marathon, v1.1.1 or above

Netsil installation can be split into two parts: **Netsil AOC** and the **collectors**.

The collectors are installed on your application servers and mirror the traffic back to Netsil AOC for analysis.

The installation instructions below use the dcos-cli, but you may do them through the Marathon UI as well.

If you wish to do so, you may install only the collectors on your mesos cluster, and install Netsil AOC elsewhere.

### Installing Netsil AOC
* Install the AOC on Marathon
    
```
$ dcos marathon app add netsil-dcos.json
```

### Installing Collectors
* Install the Collectors on Marathon

```
$ dcos marathon app add netsil-dcos-collectors.json
```

If you installed Netsil AOC outside of your mesos cluster, be sure to change the `NETSIL_SP_HOST` key in the `env` field of `netsil-dcos-collectors` to the IP address of your Netsil AOC cluster.

Also remember to change the `instances` field to reflect the number of agent nodes in your mesos cluster.

### Using Netsil
After Netsil has started up, you can access the AOC from your web browser at `https://<dcos_address>/service/netsil`, where `<dcos_address>` is the address of your DC/OS cluster.
