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

[Scaling options for applications in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/concepts-scale)

- [Cluster autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler)
- [Horizontal pod autoscaler (HPA)](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale?tabs=azure-cli)
- [Virtual nodes](https://docs.microsoft.com/en-us/azure/aks/virtual-nodes-cli)

## Links

[Stop and Start an Azure Kubernetes Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/start-stop-cluster?tabs=azure-cli)

[Use Scale-down Mode to delete/deallocate nodes in Azure Kubernetes Service (AKS) (preview)](https://docs.microsoft.com/en-us/azure/aks/scale-down-mode)

[Start and stop an Azure Kubernetes Service (AKS) node pool (Preview)](https://docs.microsoft.com/en-us/azure/aks/start-stop-nodepools)
