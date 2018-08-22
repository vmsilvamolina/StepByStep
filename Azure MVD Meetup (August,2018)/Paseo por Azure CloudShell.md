# DEMO - Paseo por Azure Cloud Shell

Paso a paso para crear una VM con CentOS desde la Azure Cloud Shell utilizando Ansible para aprovisionar.
Para la demo se utilizaron los siguientes valores:

| **Descrcipción** | **Valor utilizado en esta guía** |
| --- | --- |
| Resource group | CloudShellDEMO |
| Región en Azure | eastus |
| Nombre de la VM | WinVM |
| Nombre del usuario | vmsilvamolina |

**1-** Acceder a *Azure Cloud Shell*:

Existen varias maneras de acceder a Azure Cloud Shell, la más simple es desde el portal por medio del siguiente botón ubicado en el dashboard:



Otra forma de acceder es ingresando a la URL:

https://shell.azure.com

Donde se encuentran disponibles la posibilidad

az group create --name CloudShellDemo --location eastus
az group list --o table
az network vnet create --resource-group CloudShellDemo --name vNET --address-prefix 10.0.0.0/16 --subnet-name Subnet --subnet-prefix 10.0.1.0/24
az resource list --resource-group CloudShellDemo --o table
az vm create -n MyLinuxVM -g CloudShellDemo --image UbuntuLTS
az vm list --resource-group CloudShellDemo --o table
azure vm show CloudShellDemo MyLinuxVM | grep "Public IP address" | awk -F ":" '{print $3}'

az group delete --name CloudShellDemo

#---------------------------------------------------------------------------------

# Update for your admin password
AdminPassword=SuperPassw0rd.01
# Create a resource group.
az group create --name CloudShellDemo --location eastus
# Create a virtual network.
az network vnet create --resource-group CloudShellDemo --name myVnet --subnet-name mySubnet
# Create a public IP address.
az network public-ip create --resource-group CloudShellDemo --name myPublicIP
# Create a network security group.
az network nsg create --resource-group CloudShellDemo --name myNetworkSecurityGroup
# Create a virtual network card and associate with public IP address and NSG.
az network nic create --resource-group CloudShellDemo --name myNic --vnet-name myVnet --subnet mySubnet --network-security-group myNetworkSecurityGroup --public-ip-address myPublicIP
# Create a virtual machine. 
az vm create --resource-group CloudShellDemo --name WinVM --location eastus --nics myNic --image win2016datacenter --admin-username azureuser --admin-password $AdminPassword
# Open port 3389 to allow RDP traffic to host.
az vm open-port --port 3389 --resource-group CloudShellDemo --name WinVM
# Obtain Public IP 
azure vm show CloudShellDemo WinVM | grep "Public IP address" | awk -F ":" '{print $3}'



<#----------------------------------------------------------------------------------

# Create a resource group.
az group create --name myResourceGroup --location westeurope
# Create a virtual network.
az network vnet create --resource-group myResourceGroup --name myVnet --subnet-name mySubnet
# Create a public IP address.
az network public-ip create --resource-group myResourceGroup --name myPublicIP
# Create a network security group.
az network nsg create --resource-group myResourceGroup --name myNetworkSecurityGroup
# Create a virtual network card and associate with public IP address and NSG.
az network nic create --resource-group myResourceGroup --name myNic --vnet-name myVnet --subnet mySubnet --network-security-group myNetworkSecurityGroup --public-ip-address myPublicIP
# Create a new virtual machine, this creates SSH keys if not present.
az vm create --resource-group myResourceGroup --name myVM --nics myNic --image UbuntuLTS --generate-ssh-keys
# Open port 22 to allow SSh traffic to host.
az vm open-port --port 22 --resource-group myResourceGroup --name myVM

#>