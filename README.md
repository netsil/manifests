## About
Netsil is a next-gen observability and analytics tool for modern cloud applications. The Netsil Application Operations Center (AOC) helps SREs and DevOps improve the reliability and performance of API and microservices-driven production applications.

At the heart of the AOC is an auto-discovered service topology. It visualizes service dependencies and operational metrics so practitioners can work collaboratively across teams. 

See the "Gallery" below for some screenshots of Netsil in action!

## Instructions
Netsil installation can be split into two parts: **Netsil AOC** and the **collectors**.

The collectors are installed on your application servers and mirror the traffic back to Netsil AOC for analysis.

To install Netsil AOC and the collectors, refer to the README of the subdirectory that corresponds to your deploy environment.

After installation, you will be prompted to provide a license key, which you can create [here](https://lm.netsil.com).

## Prerequisites
### Resource Requirements
You will need to allocate a machine with sufficient resources to run Netsil AOC.
The requirements are listed below.

| Recommended | Minimum    |
| ----------- | --------   |
| 8 CPU       | 4 CPU      |
| 32 GB Mem   | 16 GB Mem  |
| 500 GB HDD  | 120 GB HDD |

### Ports
Ensure that port **443** and port **80** (optional) are open for web access to Netsil AOC through HTTPS or HTTP

Additionally, the following ports must be open to inbound traffic from the collectors:
- **2001** (TCP) for collectors metrics channel.
- **2003** (TCP and UDP) for collectors control and data channel.
- **5005** (TCP) for collectors load balancer channel.

Finally, Netsil requires an open channel to a license site for verifying your license key.
Thus, ensure that you can reach `lm.netsil.com` on port 443 from where you are running Netsil AOC.

## Support
For help please join our public [slack channel](https://netsil-users.slack.com) or email support@netsil.com 

## Gallery
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/default-map.png "Netsil Topology Main")
![alt text](https://s3.amazonaws.com/docs.netsil.com/screenshots/kube.png "Netsil Topology Kube Namespaces")
