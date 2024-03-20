echo "\n"
echo "\n"
echo echo " ===== Set Environment Variables in Local =====\n"
source "00_Variables.sh"
cat "00_Variables.sh"

echo "\n"
echo "\n"
echo " ===== Create Azure Kubernetes Service (AKS) Cluster =====\n"
az aks create --resource-group $RESOURCE_GROUP --name $AKS_NAME --node-count 1 --generate-ssh-keys --attach-acr $ACR_NAME   # --attach-acr flag: Grant the 'acrpull' role assignment to the ACR specified by name or resource ID.
# az aks install-cli    # if haven't installed yet
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
kubectl get nodes

echo "\n"
echo "\n"
echo " ===== Create Deploy and Service YAML Files =====\n"
echo "Creating model-deploy.yaml..."
echo "\
apiVersion: apps/v1
kind: Deployment
metadata:
  name: '$AKS_SERVICE_NAME'
  labels:
    app: '$AKS_SERVICE_NAME'
spec:
  replicas: 1
  selector:
    matchLabels:
      app: '$AKS_SERVICE_NAME'
  template:
    metadata:
      labels:
        app: '$AKS_SERVICE_NAME'
    spec:
      containers:
      - name: '$AKS_SERVICE_NAME'
        image: $ACR_LOGINSERVER/$IMAGE_NAME
        ports:
        - containerPort: 31311\
" > model-deploy.yaml
cat model-deploy.yaml
echo "Creating model-service.yaml..."
echo "\
apiVersion: v1
kind: Service
metadata:
  name: $AKS_SERVICE_NAME
spec:
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
      targetPort: 31311
  selector:
    app: $AKS_SERVICE_NAME\
" > model-service.yaml
cat model-service.yaml

echo "\n"
echo "\n"
echo " ===== Run and Deploy =====\n"
kubectl apply -f "model-deploy.yaml"
kubectl apply -f "model-service.yaml"
sleep 60

echo "\n"
echo "\n"
echo " ===== Get Prediction =====\n"
PUBLIC_IP=$(kubectl get service mlflow-serving --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -v http://$PUBLIC_IP/

python3 generate_sample_request_data.py
RESPONSE=$(curl --header "Content-Type: application/json" --request POST --data "@./sample_request_data/sample_request_data.json" http://$PUBLIC_IP/score)
echo $RESPONSE
echo $RESPONSE > sample_response.json
python3 visualize_detections.py