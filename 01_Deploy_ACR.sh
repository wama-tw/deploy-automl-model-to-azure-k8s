echo "\n"
echo "\n"
echo echo " ===== Set Environment Variables in Local =====\n"
source "00_Variables.sh"
cat "00_Variables.sh"

echo "\n"
echo "\n"
echo " ===== Run in Docker to Test Locally =====\n"
docker build -t mlflow-image .
CONTAINER_ID=$(docker run --rm -d -p 5001:31311 mlflow-image)
## --rm flag: Automatically remove the container when it exits
## -d(--detach): Run container in background and print container ID
## -p(--publish): Publish a container’s port(s) to the host
echo $CONTAINER_ID
sleep 5

echo "\n"
echo "\n"
echo " ===== Testing for Response =====\n"
curl --header "Content-Type: application/json" --request POST --data "@./sample_request_data/sample_request_data.json" 127.0.0.1:5001/score

echo "\n"
echo "\n"
echo " ===== Create a Docker Image From the Running Container =====\n"
docker ps
docker commit $CONTAINER_ID $IMAGE_NAME
docker stop $CONTAINER_ID

echo "\n"
echo "\n"
echo " ===== Create ACR =====\n"
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
az acr login --name $ACR_NAME   # Log in to an Azure Container Registry through the Docker CLI, use 'docker logout ' to log out.
# ACR_LOGINSERVER=$(az acr list --resource-group $RESOURCE_GROUP --query "[].{acrLoginServer:loginServer}" --output tsv)
az acr list --resource-group $RESOURCE_GROUP --query "[].{acrLoginServer:loginServer}" --output tsv
ACR_LOGINSERVER=$(echo $ACR_NAME.azurecr.io)
echo "Login Server: $ACR_LOGINSERVER"
docker tag $IMAGE_NAME $ACR_LOGINSERVER/$IMAGE_NAME
docker push $ACR_LOGINSERVER/$IMAGE_NAME
docker logout
