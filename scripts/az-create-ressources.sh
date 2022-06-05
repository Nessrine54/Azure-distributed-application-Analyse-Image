#!/bin/bash

SUBSCRIPTION_ID=$1
RESOURCES_GROUP=$2
MONGO_DB_NAME=ImageDescribe
RESOURCE_STORAGE_NAME=$3
COSMOS_DB_NAME=cosmosdbstoragedescribe
COGNITIVE_SERVICES_NAME=ComputerVisionAnalyse

# Create Resource Groupe
az group create --location ukwest --name $RESOURCES_GROUP --subscription $SUBSCRIPTION_ID
sleep 5

#Create and configure Storage Account
az storage account create --name $RESOURCE_STORAGE_NAME --resource-group $RESOURCES_GROUP --access-tier Hot --allow-blob-public-access true --https-only true --kind StorageV2 --location ukwest --sku Standard_RAGRS
sleep 10

KEY=$(az storage account keys list -g $RESOURCES_GROUP -n $RESOURCE_STORAGE_NAME --query [0].value -o tsv)

az storage cors add --methods DELETE GET HEAD MERGE OPTIONS POST PUT --origins "*" --allowed-headers "*" --exposed-headers "*" --services b --account-key $KEY --account-name $RESOURCE_STORAGE_NAME --sas-token "?$(az storage account generate-sas --expiry 2022-12-30T12:00Z --permissions rwdlac --resource-types sco --services b --account-key $KEY --account-name $RESOURCE_STORAGE_NAME)"
az storage container create --name tutorial-container --account-key $KEY --account-name $RESOURCE_STORAGE_NAME --public-access container
sleep 10

#Create CosmosDB API MongoDB
az cosmosdb create --name $COSMOS_DB_NAME --resource-group $RESOURCES_GROUP --kind MongoDB --server-version 4.0 --default-consistency-level Eventual --enable-automatic-failover true --locations regionName="UK West" failoverPriority=0 isZoneRedundant=False
sleep 10
az cosmosdb mongodb database create --account-name $COSMOS_DB_NAME --resource-group $RESOURCES_GROUP --name $MONGO_DB_NAME 
az cosmosdb mongodb collection create --account-name $COSMOS_DB_NAME --resource-group $RESOURCES_GROUP --database-name $MONGO_DB_NAME --name describe
MONGO_DB_URL=$(az cosmosdb list-connection-strings --name $COSMOS_DB_NAME --resource-group $RESOURCES_GROUP --query connectionStrings[0].connectionString --output tsv)
sleep 10

#Create CognitivesServices
az cognitiveservices account create --name $COGNITIVE_SERVICES_NAME --resource-group $RESOURCES_GROUP --kind ComputerVision --sku F0 -l uksouth
COGNITIVE_SERVICES_KEY=$(az cognitiveservices account keys list --resource-group $RESOURCES_GROUP --name $COGNITIVE_SERVICES_NAME --query key1 --output tsv)
sleep 10

# Create funcapp
cd ../azure_func
az functionapp create --name GetImageDescribe --resource-group $RESOURCES_GROUP --consumption-plan-location ukwest --runtime python --functions-version 4 --storage-account $RESOURCE_STORAGE_NAME --os-type Linux
sleep 10
az functionapp config appsettings set --name GetImageDescribe --resource-group  $RESOURCES_GROUP --settings "KEY=$COGNITIVE_SERVICES_KEY" "blobstorage=DefaultEndpointsProtocol=https;AccountName=$RESOURCE_STORAGE_NAME;AccountKey=$KEY;EndpointSuffix=core.windows.net" "MONGO_URL=$MONGO_DB_URL" "BLOB_STORAGE_URL=https://$RESOURCE_STORAGE_NAME.blob.core.windows.net/" "COMPUTER_VISION_ANALYSE_URL=https://uksouth.api.cognitive.microsoft.com/"
sleep 10
func azure functionapp publish GetImageDescribe
az functionapp cors add --resource-group $RESOURCES_GROUP --name GetImageDescribe --allowed-origins "*"
cd ../scripts