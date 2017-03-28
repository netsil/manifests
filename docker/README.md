## Pre-installation Instructions
Prerequisites
- Docker daemon, running v1.10.0 or above

Netsil installation can be split into two parts: **Netsil AOC** and the **collectors**.

The collectors are installed on your application servers and mirror the traffic back to Netsil AOC for analysis.


## Resource Requirements
You will need to allocate a machine with sufficient resources to run Netsil AOC. 

For your Netsil AOC instance, we recommend:

- 8 CPU
- 32 GB Memory
- 500 GB Hard Disk Space


### Installing Netsil AOC
* To install the AOC, run the following script
    
This will pull and run the Netsil AOC docker image.
```
$ install-netsil.sh
```

* You may also run Netsil AOC with docker-compose, if you prefer:
```
$ docker-compose up -d
```


### Installing Collectors
* To install the collectors as a container, run the following script with the address of your Netsil AOC in the environment

This will pull and run the Netsil Collectors docker image.
```
NETSIL_HOST=<Your AOC address here> install-netsil-collectors.sh
```

### Using Netsil
After Netsil has started up, you can access the AOC from your web browser at `https://<Your AOC address>` 
