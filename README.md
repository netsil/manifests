## About
Netsil Application Operations Center (AOC) is a next-gen observability and analytics tool for modern cloud applications. The Netsil AOC helps SREs and DevOps improve the reliability and performance of API and microservices-driven production applications.

At the heart of the AOC is an auto-discovered service topology map. It visualizes service dependencies and operational metrics so practitioners can work collaboratively across teams.

See the "Gallery" below for some screenshots of Netsil in action!

## Introduction
Installation is done in two parts: **Netsil AOC** and the **Netsil Collectors**.

The collectors are installed on your application instances (VMs or containerized environments) and mirror the service interactions & metrics back to Netsil AOC for real-time analysis.

You may install the collectors in a variety of environments, independent of the AOC environment. For instance, you may run the AOC as a standalone docker container, but install the collectors in Kubernetes.

## Installation
To install the AOC, refer to the subdirectory of this repository that corresponds to your deploy environment.

To install the collectors, refer to the `Documentation > Collectors` tab within your AOC instance.

## Documentation
The instructions below should be enough to get you started. However, you can browse through our [full documentation](https://netsil.github.io/docs), which provides API definitions, user guides, and more. 

You may also reach this site from the `Documentation` tab within your AOC instance. The documentation within the AOC is more likely to be in-sync with your current version of Netsil.

## Resource Requirements
You will need to provide a machine with sufficient resources to run Netsil AOC:

|  |**Recommended**|**Minimum**|
|:---:|:---:|:---:|
|vCPUs| 8 (or more) | 4 |
|Memory| 32 GiB (or more) | 16 GiB |
|Disk| 1 TB (or more) | 500 GiB |

## Ports and Firewall Rules
### Inbound
Please open the inbound ports listed below. The "Your Private Subnet" source refers to the subnet where you are installing the collectors.

| **Port** | **Protocol** | **Source** |
|:--------:|:------------:|:----------:|
| 443      | TCP          | 0.0.0.0/0     |
| 80       | TCP          | 0.0.0.0/0     |
| 2001     | TCP          | Your Private Subnet |
| 2003     | TCP          | Your Private Subnet |
| 2003     | UDP          | Your Private Subnet |

- If you wish, you may also open port `22 (TCP)` for `SSH` access.
- If you are deploying Netsil AOC behind a load balancer, make sure to use layer 4 load balancing instead of layer 7 to properly proxy WebSocket connections.
- At the basic level, ensure that your Netsil AOC instance is reachable from the network where you are installing the collectors.

### Outbound
Netsil requires an open channel to a license site for verifying your license key.
Thus, ensure that you can reach `lm.netsil.com` on port 443 from where you are running Netsil AOC.

## Usage
You may access the Netsil AOC Web UI at:
```
http[s]://<your.netsil.ip>
```
## Support
For help please join our public [slack channel](http://slack.netsil.com) or email support@netsil.com

## Gallery
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/default-map.png "Netsil Topology Main")
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/kube.png "Netsil Topology Kube Namespaces")
