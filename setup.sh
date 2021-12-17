#!/bin/bash

# All the variables for the deployment
subscriptionName="AzureDev"
aadAdminGroupContains="janne''s"

aksName="myaksscaling"
workspaceName="myscalingworkspace"
vnetName="myaksscaling-vnet"
subnetAks="AksSubnet"
identityName="myaksscaling"
resourceGroupName="rg-myaksscaling"
location="westeurope"

# Login and set correct context
az login -o table
az account set --subscription $subscriptionName -o table

subscriptionID=$(az account show -o tsv --query id)
az group create -l $location -n $resourceGroupName -o table

# Prepare extensions and providers
az extension add --upgrade --yes --name aks-preview

# Enable features
az feature register --namespace "Microsoft.ContainerService" --name "AKS-ScaleDownModePreview"
az feature register --namespace "Microsoft.ContainerService" --name "PodSubnetPreview"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-ScaleDownModePreview')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSubnetPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService

# Remove extension in case conflicting previews
# az extension remove --name aks-preview

aadAdmingGroup=$(az ad group list --display-name $aadAdminGroupContains --query [].objectId -o tsv)
echo $aadAdmingGroup

workspaceid=$(az monitor log-analytics workspace create -g $resourceGroupName -n $workspaceName --query id -o tsv)
echo $workspaceid

vnetid=$(az network vnet create -g $resourceGroupName --name $vnetName \
  --address-prefix 10.0.0.0/8 \
  --query newVNet.id -o tsv)
echo $vnetid

subnetaksid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetAks --address-prefixes 10.2.0.0/20 \
  --query id -o tsv)
echo $subnetaksid

identityid=$(az identity create --name $identityName --resource-group $resourceGroupName --query id -o tsv)
echo $identityid

az aks get-versions -l $location -o table

# Note: for public cluster you need to authorize your ip to use api
myip=$(curl --no-progress-meter https://api.ipify.org)
echo $myip

# Note about private clusters:
# https://docs.microsoft.com/en-us/azure/aks/private-clusters

# For private cluster add these:
#  --enable-private-cluster
#  --private-dns-zone None

# Choose correct OS disk and VM size
# osDisk="Ephemeral" # Requires Standard_D8ds_v4 or similar
# vmSize="Standard_D8ds_v4"
osDisk="Managed"
vmSize="Standard_D4ds_v4"

az aks create -g $resourceGroupName -n $aksName \
 --max-pods 50 --network-plugin azure \
 --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 2 \
 --node-osdisk-type $osDisk \
 --node-vm-size $vmSize \
 --kubernetes-version 1.21.2 \
 --enable-addons monitoring \
 --enable-aad \
 --enable-managed-identity \
 --disable-local-accounts \
 --aad-admin-group-object-ids $aadAdmingGroup \
 --workspace-resource-id $workspaceid \
 --load-balancer-sku standard \
 --vnet-subnet-id $subnetaksid \
 --assign-identity $identityid \
 --api-server-authorized-ip-ranges $myip \
 -o table 

nodepool1="nodepool1"
az aks nodepool scale -g $resourceGroupName --cluster-name $aksName \
  --name $nodepool1 \
  --node-count 2

nodepool2="nodepool2"
az aks nodepool add -g $resourceGroupName --cluster-name $aksName \
  --name $nodepool2 \
  --node-count 3 \
  --node-osdisk-type $osDisk \
  --node-vm-size $vmSize \
  --scale-down-mode Deallocate \
  --node-osdisk-type Managed \
  --node-taints "usage=tempworkloads:NoSchedule" \
  --labels usage=tempworkloads \
  --max-pods 150

# az aks nodepool delete -g $resourceGroupName --cluster-name $aksName --name $nodepool2

time az aks nodepool scale -g $resourceGroupName --cluster-name $aksName \
  --name $nodepool2 \
  --node-count 1 \
  -o none

time az aks nodepool scale -g $resourceGroupName --cluster-name $aksName \
  --name $nodepool2 \
  --node-count 3 \
  -o none

az aks nodepool update -g $resourceGroupName --cluster-name $aksName \
  --name $nodepool2 \
  --node-count 2 \
  --scale-down-mode Delete

###################################################################
# Enable current ip
az aks update -g $resourceGroupName -n $aksName --api-server-authorized-ip-ranges $myip

# Clear all authorized ip ranges
az aks update -g $resourceGroupName -n $aksName --api-server-authorized-ip-ranges ""
###################################################################

sudo az aks install-cli

az aks get-credentials -n $aksName -g $resourceGroupName --overwrite-existing

kubectl get nodes
kubectl get nodes --show-labels=true
kubectl get nodes -L agentpool,usage

# Deploy all items from demos namespace
kubectl apply -f demos/namespace.yaml
kubectl apply -f demos/deployment.yaml
kubectl apply -f demos/service.yaml

kubectl get deployment -n demos
kubectl describe deployment -n demos

kubectl get pod -n demos
kubectl get pod -n demos -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'

# Get number of pods per node
kubectl get pod -n demos --no-headers=true -o custom-columns=NODE:'{.spec.nodeName}' | sort | uniq -c | sort -n

pod1=$(kubectl get pod -n demos -o name | head -n 1)
echo $pod1

kubectl describe $pod1 -n demos

kubectl get service -n demos

ingressip=$(kubectl get service -n demos -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $ingressip

curl $ingressip

# Wipe out the resources
az group delete --name $resourceGroupName -y
