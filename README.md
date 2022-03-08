# Deployment on Microsoft Azure Kubernetes Service (AKS) using docker container 

The following commands can be used in Azure Cloud Shell via the browser.  First you need to login to (Azure Portal)[] then click on Cloud Shell using Bash.
You can see steps by steps instruction (here)[https://medium.com/@phylypo/deploy-a-pycaret-app-to-aks-using-azure-container-registry-fc9e56c378d0].

``
# setup variables to use
RESOURCE_GROUP=PYCARET-KUBE-RG
CLUSTER_NAME=PYCARET-AKS
ACR_NAME=pycaretacr

# create resource group, make sure the resource gropu name is new so we can cleanup at the end
az group create --name $RESOURCE_GROUP --location westus2

# create Aure Container Registry (ACR)
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Premium

# clone the git repo and go into repo directory
# git clone https://...
cd pycaret-deployment-azure

# build and put the docker image to Azure registry
az acr build --registry $ACR_NAME --image pycaret-ins-5000:v1 .

# create kubernetes cluster
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 2 \
    --enable-addons http_application_routing \
    --enable-managed-identity \
    --generate-ssh-keys \
    --node-vm-size Standard_B2s

# add node pool
az aks nodepool add \
    --resource-group $RESOURCE_GROUP \
    --cluster-name $CLUSTER_NAME \
    --name mypool \
    --node-count 2 \
    --node-vm-size Standard_B2s 


# Setup credential to the AKS cluster
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP

# Enable the access key using Azure portal on ACR
# Copy the username and primary key for below command

# Create Kubernetes secret with username and password for access to private registry
# updat the <USER_NAME> and <YOUR_KEY> for the command below
kubectl create secret docker-registry azure-reg-cred \
    --docker-username=<USER_NAME> \
    --docker-password=<YOUR_KEY> \
    --docker-server=pycaretacr.azurecr.io

# create deployment and service on AKS
kubectl apply -f azure_deployment.yaml

# check pod status for running status
kubectl get pod
# check for service ip
kubectl get service

# Your should be able to browse to the EXTERNAL-IP from above output and you should see the web interface

# Cleanup -- when done, use the command below to delete the resource group 
# this will also delete all the resources in this resource group so you don't incure any futher cost
az group delete --name $RESOURCE_GROUP --yes --no-wait
``
