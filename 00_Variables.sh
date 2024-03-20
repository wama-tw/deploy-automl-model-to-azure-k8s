RESOURCE_GROUP='wama'  # Resource Group name
IMAGE_NAME='mlflow-image:latest'
ACR_NAME='mlflowacrimage'     # Azure Container Registry registry name
ACR_LOGINSERVER=$(echo $ACR_NAME.azurecr.io)
AKS_NAME='mlflowcluster'
AKS_SERVICE_NAME='mlflow-serving'