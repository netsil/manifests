## Pre-installation Instructions
Prerequisites
- Docker daemon, running v1.10.0 or above

### Installing Netsil AOC
* Pull and run Netsil AOC with `docker run` command
```
$ ./install-netsil.sh
```

* Alternatively, you may use docker-compose
```
$ docker-compose up -d
```

### Installing Collectors
* Run a collector 

Remember to specify the address of your Netsil AOC instance
```
NETSIL_HOST=<Your AOC address here> ./install-netsil-collectors.sh
```

### Using Netsil
After Netsil has started, you can access the AOC from your web browser at `https://<Your AOC address>` 
