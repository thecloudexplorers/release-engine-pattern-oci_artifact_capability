metadata resources = {
  version: '0.1.0'
  author: 'Wesley Camargo'
  company: 'The Cloud Explorers'
  description: 'Deploys a resource group and an Azure Container Registry using Azure Verified Modules.'
}

// WORKLOAD CONFIGURATIONS

// scope must be set to subscription to allow for the creation of a resource group
targetScope = 'subscription'

param tags object

@description('Name of the target resource group ')
param resourceGroupName string

@allowed([
  'westeurope'
])
@description('Location for all resources.')
param location string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('The SKU of the Azure Container Registry.')
param acrSku string

@description('Name of the Azure Container Registry.')
param containerRegistryName string

// Creates unique deployment names to avoid conflicts
var deploymentNames = {
  resourceGroup: 'resourceGroupName${uniqueString(resourceGroupName, deployment().name)}'
  containerRegistry: 'containerRegistryName${uniqueString(resourceGroupName, deployment().name)}'
}

module resourceGroup 'br/public:avm/res/resources/resource-group:0.4.2' = {
  name: deploymentNames.resourceGroup
  params: {
    name: resourceGroupName
    tags: tags
  }
}

module containerRegistry 'br/public:avm/res/container-registry/registry:0.9.3' = {
  name: deploymentNames.containerRegistry
  scope: az.resourceGroup(resourceGroupName)
  dependsOn: [
    resourceGroup
  ]
  params: {
    name: containerRegistryName
    acrSku: acrSku
    location: location
  }
}

output resourceGroupId string = resourceGroup.outputs.resourceId
