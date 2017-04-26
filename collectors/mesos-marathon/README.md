### Installation
The installation instructions below use the dcos-cli, but you may use the Marathon UI as well.

```
$ dcos marathon app add netsil-dcos-collectors.json
```

If you installed Netsil AOC outside of your mesos cluster, be sure to change the `NETSIL_SP_HOST` key in the `env` field of `netsil-dcos-collectors` to the IP address of your Netsil AOC cluster.

Also remember to change the `instances` field to reflect the number of agent nodes in your mesos cluster.
