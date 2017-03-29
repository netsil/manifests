## About
Netsil is a next-gen observability and analytics tool for modern cloud applications. The Netsil Application Operations Center (AOC) helps SREs and DevOps improve the reliability and performance of API and microservices-driven production applications.

At the heart of the AOC is an auto-discovered service topology, which is rendered from live service interaction analysis. It allows practitioners to visualize their service dependencies and operational metrics and work collaboratively across teams. 

See the "Gallery" below for some screenshots of Netsil in action!

## Instructions
Netsil installation can be split into two parts: **Netsil AOC** and the **collectors**.

The collectors are installed on your application servers and mirror the traffic back to Netsil AOC for analysis.

To install Netsil AOC and the collectors, refer to the README of the subdirectory that corresponds to your deploy environment.

## Prerequisites and Resource Requirements
You will need to allocate a machine with sufficient resources to run Netsil AOC. 

For your Netsil AOC instance, we recommend:

- 8 CPU
- 32 GB Memory
- 500 GB Hard Disk Space

## Gallery
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/default-map.png "Netsil Topology Main")
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/kube.png "Netsil Topology Kube Namespaces")
