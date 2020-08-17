# Public Azure Kubernetes Cluster with Linux and Windows NodePools

This repo shows how to provision an environment for working with a private AKS cluster.
It includes.
- An AKS cluster
- 2 virtual networks peered to simulate a hub/spoke model of resource placement
- A Container Registry (ACR)
- A Key Vault - Can be used by AKS as a [secret store](https://github.com/Azure/secrets-store-csi-driver-provider-azure)
- A SQL Azure instance - to show connectivity to network resources
- An App Gateway - Can be used by AKS as a WAF enabled [ingress controller](https://azure.github.io/application-gateway-kubernetes-ingress/)
- A Log Analytics workspace

## Pre-requisites

You will need the following installed to deploy this (versions I used show in brackets)
- Azure CLI (v2.3.0)
- Terraform (v0.12.24)
- Powershell Core (v7.0.0)
- An Azure Subscription
- An Azure DevOps Account (and the ability to generate Service Connections/Pipelines/Manage Build Agents)


## Getting ready to run Terraform

First you need to generate the certificate that is required by the P2S VPN, run the [CreateVPNCerts.ps1](Terraform/scripts/CreateVPNCerts.ps1) script in powershell to create and register a new self-signed cert.
In the Terraform folder create a file called terraform.tfvars, this will contain the variables you pass to create your environment.
The file should contain the following...

    location = "<THE AZURE LOCATION TO DEPLOY YOUR RESOURCES>"
    prefix = "<A 5 CHARACTER PREFIC THAT WILL MAKE YOUR DEPLOYMENT UNIQUE>"
    aad-aks-group-id = "<THE OBJECT ID OF AN AAD GROUP USED TO MANAGE THE CLUSTER>

for example

    location = "centralus"
    prefix = "mfaks"
    aad-aks-group-id = "00000000-0000-0000-0000-000000000000"

Save this file and open up a powershell window.
navigate to the Terraform folder.
Log in to you azure account using 

    az login
Select the correct subscription using

    az account list
and then 

    az account set --subscription "<SUBSCRIPTION NAME OR ID>"

Now Initialize Terraform

    terraform init

and finally run with (note the auto-approve flag skips the manual verification step)

    terraform apply -auto-approve

This will take about 20 minutes to provision everything.
When it is complete you should have 1 build agent configured and active per group in azure DevOps.
![Configured DevOps Agent](/images/DevOpsConfiguredAgent.png "Configured DevOps Agent")

## Deploy a sample project

I am using my [sample aks app repository](https://github.com/fortunkam/simpleaksapp) to test the deploys (clone to a devops repository, build the 2 docker files, push to acr, modify the yaml to point at your acr and then deploy to AKS).  Next steps for this project are to add a DevOps yaml multistage pipeline for testing.


## Useful links

https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks

https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html

https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal

https://github.com/Azure/secrets-store-csi-driver-provider-azure

https://azure.github.io/application-gateway-kubernetes-ingress/


