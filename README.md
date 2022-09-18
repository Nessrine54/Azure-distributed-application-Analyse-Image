# Azure distributed app image analyzer https://imageanalyzerapp.azurewebsites.net/
**Auteur**: AFFES BILEL 

Ce projet est une application distribuée permettant de :
- Stocker une image dans un blob storage.
- Analyser l'image grâce à azure cognitive services et récupérer sa descritption.
- Stocker la description dans un database cosmosDB API mongoDB.
- Afficher la liste des descriptions à l'utilisateur.

## Prérequis

- Git pour cloné le repo.
- Node.js et NPM.
- Web browser.
- Azure subscription et Azure Cli pour créer les ressources.

## Arborescence projet
Ce projet est composé de :
- Un dossier **src** contenant les sources de l'application écrite en ReactJS.
- Un dossier **script** contenant :
    - Un fichier  **az-create-ressources.sh** permettant de créer et déployer les ressources azure nécéssaire au projet.
    - Un fichier **az-delete-ressources.sh** pour supprimer toutes les ressources azure créées.
- Un dossier **azure_func** contenant les azure functions :
    - MyBlobTrigger.
    - MyHTTPTrigger.

## Mode d'emploie
Pour lancer le projet il faut :
1. Installer les dépendances de l'application :
    - `` npm install ``
2. Aller dans le dossier scripts :
    - `` cd scripts ``
3. lancer le script de création de ressources :
    - `` ./az-create-ressources.sh <SUBSCRIPTION_ID> <RESOURCES_GROUP> <RESOURCE_STORAGE_NAME> ``
4. Vérifier que le **endpoint** du cognitives services corespond bien à la valeur de la variable **COMPUTER_VISION_ANALYSE_URL**, dans la configuration de la fonctions app.
5. Une fois que la création des ressources est fini, revenir à la racine du projet et lancer l'application :
    - `` REACT_APP_SAS_TOKEN=<REACT_APP_SAS_TOKEN> REACT_APP_STORAGE_ACCOUNT_NAME=<REACT_APP_STORAGE_ACCOUNT_NAME> REACT_APP_GET_DESCRIBE_URL=<URL_AZURE_FUNCTION_HTTP_TRIGGER> npm start ``
6. Une fenêtre dans le browser va s'ouvrire sur l'url **http://localhost:3000**. Vous aurez trois boutons :
    - **Choisir un fichier** permettant de choisir une image.
    - **Upload** permettant d'uploder l'image et la stocker dans le blob storage. la stockage de l'image va déclancher le **blobTrigger** qui va analyser l'image, recupérer la descritpion et la stocker dans la DB.
    - **getDescribeImage** permettant de récupérer la liste des descriptions stocker dans la DB et les afficher à l'utilisateur. (PS: L'affichage de la liste est un peu lent et prend un peu de temps, donc patientez un peu pour voir la liste :) ).

## Déploiement
Pour déployer l'application web il faut :
1. Créer un container registry :
    - `` az acr create --name <REGISTRY_NAME> --resource-group <RESOURCE_GROUP> --sku standard --admin-enabled true ``
2. Builder l'image docker et la pusher dans la registry:
    - `` az acr build --file Dockerfile --registry <REGISTRY_NAME>  --image <IMAGE_NAME> ``
3. Créer la plan de l'app service:
    - `` az appservice plan create --resource-group <RESOURCE_GROUP> --name <PLAN_NAME> --is-linux --sku B1 ``
4. Créer la WebApp :
    - `` az webapp create --resource-group <RESOURCE_GROUP> --plan <PLAN_NAME> --name <APP_NAME> --deployment-container-image-name  <REGISTRY_NAME>.azurecr.io/<IMAGE_NAME> ``
5. Configurer les variables d'env de l'app :
    - `` az webapp config appsettings set --resource-group <RESOURCE_GROUP> --name <APP_NAME> --settings "REACT_APP_SAS_TOKEN=<REACT_APP_SAS_TOKEN>" "REACT_APP_STORAGE_ACCOUNT_NAME=<REACT_APP_STORAGE_ACCOUNT_NAME>" "REACT_APP_GET_DESCRIBE_URL=<URL_AZURE_FUNCTION_HTTP_TRIGGER>" ``
6. L'app aura comme nom de domaine : **https://<APP_NAME>.azurewebsites.net/**
