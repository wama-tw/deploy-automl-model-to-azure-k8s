echo "\n"
echo "\n"
echo echo " ===== Set Environment Variables in Local =====\n"
source "00_Variables.sh"
cat "00_Variables.sh"

echo "\n"
echo "\n"
echo " ===== Clean Up Resource ====="
az acr delete --name $ACR_NAME -g $RESOURCE_GROUP --yes
az aks delete --name $AKS_NAME -g $RESOURCE_GROUP --yes
kubectl config delete-context $AKS_NAME