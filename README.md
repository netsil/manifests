## About
Netsil Application Operations Center (AOC) is a next-gen observability and analytics tool for modern cloud applications. The Netsil AOC helps SREs and DevOps improve the reliability and performance of API and microservices-driven production applications.

At the heart of the AOC is an auto-discovered service topology map. It visualizes service dependencies and operational metrics so practitioners can work collaboratively across teams. 

See the "Gallery" below for some screenshots of Netsil in action!

## Introduction
Installation is done in two parts: **Netsil AOC** and the **Netsil Collectors**.

The collectors are installed on your application instances (VMs or containerized environments) and mirror the service interactions & metrics back to Netsil AOC for real-time analysis.

You may install the collectors in a variety of environments, independent of the AOC environment.
For instance, you may run the AOC as a standalone docker container, but install the collectors in Kubernetes.

## Installation
To install the AOC, refer to the subdirectory of this repository that corresponds to your deploy environment.

To install the collectors, refer to the `Documentation > Collectors` tab within your AOC instance.

## Documentation
The instructions below should be enough to get you started. However, you can browse through our [full documentation](https://netsil.github.io/docs), which provides API definitions, user guides, and more. 

You may also reach this site from the `Documentation` tab within your AOC instance. The documentation within the AOC is more likely to be in-sync with your current version of Netsil.

## Prerequisites
### Resource Requirements
You will need to allocate an instance with sufficient resources to run Netsil AOC.
The requirements are listed below.

| Recommended | Minimum    |
| ----------- | --------   |
| 8 CPU       | 4 CPU      |
| 32 GB Mem   | 16 GB Mem  |
| 500 GB HDD  | 120 GB HDD |

### Ports
Ensure that port **443** and port **80** (optional) are open for web access to Netsil AOC through HTTPS or HTTP

Additionally, the following ports must be open on the AOC host to receive inbound traffic from the collectors:
- **2001** (TCP) for collectors metrics channel.
- **2003** (TCP) for collectors control channel.
- **3003** (TCP) for collectors data channel.

Finally, Netsil requires an open channel to a license site for verifying your license key.
Thus, ensure that you can reach `lm.netsil.com` on port 443 from where you are running Netsil AOC.

## Support
For help please join our public [slack channel](http://slack.netsil.com) or email support@netsil.com

## Gallery
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/default-map.png "Netsil Topology Main")
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/kube.png "Netsil Topology Kube Namespaces")
