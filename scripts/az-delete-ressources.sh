#!/bin/bash

SUBSCRIPTION_ID=$1
RESOURCES_GROUP=$2
RESOURCES_STORAGE_NAME=$3

az functionapp delete --resource-group $RESOURCES_GROUP --name GetImageDescribe
az cognitiveservices account delete --name ComputerVisionAnalyse --resource-group $RESOURCES_GROUP
az resource delete --ids /subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.CognitiveServices/locations/uksouth/resourceGroups/$RESOURCES_GROUP/deletedAccounts/ComputerVisionAnalyse
az cosmosdb delete --name cosmosdbstoragedescribe --resource-group $RESOURCES_GROUP --yes
az storage account delete --name $RESOURCES_STORAGE_NAME --resource-group $RESOURCES_GROUP --yes
az group delete --name $RESOURCES_GROUP --yes