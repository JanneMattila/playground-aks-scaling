# Playground AKS Scaling

Playground for AKS and scaling

## Usage

1. Clone this repository to your own machine
2. Open Workspace
  - Use WSL in Windows
  - Requires Bash
3. Open [setup.sh](setup.sh) to walk through steps to deploy this demo environment
  - Execute different script steps one-by-one (hint: use [shift-enter](https://github.com/JanneMattila/some-questions-and-some-answers/blob/master/q%26a/vs_code.md#automation-tip-shift-enter))

## Discussion topics

[Scaling options for applications in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/concepts-scale)

- [Cluster autoscaler](https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler)
- [Horizontal pod autoscaler (HPA)](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale?tabs=azure-cli)
- [Vertical Pod autoscaler (VPA)](https://learn.microsoft.com/en-us/azure/aks/vertical-pod-autoscaler)
- [Virtual nodes](https://learn.microsoft.com/en-us/azure/aks/virtual-nodes-cli)

## Re-create vs. start+stop vs. scale to zero

To optimize your compute costs, you might be looking for different options
to achieve that:

- Drop and re-create cluster
  - It takes *n* minutes to re-create cluster
  - You need to re-deploy all your workloads to the empty cluster
- [Stop and start cluster](https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster)
  - It takes *n* minutes to start cluster
  - **[Limitations:](https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster?tabs=azure-cli#limitations)**
    - The customer provisioned PrivateEndpoints linked to private cluster need to be deleted and recreated again when you start a stopped AKS cluster
    - When you start your cluster, **the IP address of your API server may change**
- [Stop and start User node pools](https://learn.microsoft.com/en-us/azure/aks/start-stop-nodepools) _Preview_
  - You still have `System node pools` running
  - It takes *n* minutes to start node pool
- [Scale User node pools to zero](https://learn.microsoft.com/en-us/azure/aks/scale-cluster#scale-user-node-pools-to-0)
  - You still have `System node pools` running
  - It takes *n* minutes to scale to target node pool size
  - You can use `Scale-down Mode` [deallocate](https://learn.microsoft.com/en-us/azure/aks/scale-down-mode) (_Preview_)
    to improve scale up time

In case of [Private AKS](https://learn.microsoft.com/en-us/azure/aks/private-clusters),
you need to also consider your DNS infrastructure support for your selected option.
Some Azure CLI options to check:
- `--enable-public-fqdn` (_if this option is allowed in your organization_)
  - Creates Public FQDN for your Private AKS API server endpoint
- `--private-dns-zone [system|Private DNS Zone Resource ID]`
  - Creates Private DNS Zone entry for your Private AKS API server endpoint

See [Configure Private DNS Zone](https://learn.microsoft.com/en-us/azure/aks/private-clusters#configure-private-dns-zone)
for more details.

## Links

[Stop and Start an Azure Kubernetes Service (AKS) cluster](https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster?tabs=azure-cli)

[Use Scale-down Mode to delete/deallocate nodes in Azure Kubernetes Service (AKS) (preview)](https://learn.microsoft.com/en-us/azure/aks/scale-down-mode)

[Start and stop an Azure Kubernetes Service (AKS) node pool (Preview)](https://learn.microsoft.com/en-us/azure/aks/start-stop-nodepools)
