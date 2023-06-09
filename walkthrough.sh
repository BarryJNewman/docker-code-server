docker build   --no-cache   --pull -t codevault.azurecr.us/codeserver:v1 .

az cloud set --name AzureUSGovernment
az login
resource_group_name="Prod-ACR-RG"
registry_name="codevault.azurecr.us"
appservice_plan_name="CodeVault"
appservice_sku="P2V2"
app_name="CodeVault2"

az group create --name $resource_group_name --location usgovvirginia

az acr create --resource-group $resource_group_name \
  --name codevault --sku Basic

az acr login --name $registry_name
az acr update -n $registry_name --admin-enabled true
#docker tag lscr.io/linuxserver/code-server $registry_name/codeserver:v1

#docker build   --no-cache --pull -t $registry_name/codeserver:v1 .

az acr build --image $registry_name/codeserver:v1 \
  --registry $registry_name \
  --file Dockerfile .

docker push $registry_name/codeserver:v1 -force

docker build   --no-cache --push -t codevault.azurecr.us/codeserver:v1 --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" --squash .

docker build   --no-cache --pull -t codevault.azurecr.us/codeserver:v1 --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" --squash .

docker run -d --name=codeserver -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC -e DEFAULT_WORKSPACE=/config/workspace `#optional` -p 443:443 -v config:/config --restart unless-stopped codevault.azurecr.us/codeserver:v1


### create web app and assign perms
az appservice plan create --name $appservice_plan_name --resource-group $resource_group_name --sku $appservice_sku --is-linux
az webapp create --resource-group $resource_group_name --plan $appservice_plan_name --name $app_name --deployment-container-image-name codevault.azurecr.us/codeserver:v1
az webapp identity assign --name $app_name --resource-group $resource_group_name
principalid=$(az webapp identity show --name $app_name --resource-group $resource_group_name --query principalId -o tsv)
acrscope=$(az acr show --name $registry_name --resource-group $resource_group_name --query id -o tsv)
az role assignment create --assignee $principalid --scope $acrscope --role AcrPull



ACR_ID=$(az acr show --name $registry_name --query id --output tsv)
SP_PASSWD=$(az ad sp create-for-rbac --name IaC_4_ACR --role Reader --scopes $ACR_ID --query password --output tsv)
#APP_ID=$(az ad sp list --query "[?contains(displayname, 'IaC_4_ACR')].appId | [0]" --output tsv)
APP_ID=$(az ad sp list --display-name "IaC_4_ACR" --query "[].{id:appId} | [0]" --output tsv)
az webapp config set --resource-group $resource_group_name --name $app_name --generic-configurations '{"acrUseManagedIdentityCreds": true}'
az webapp config container set --name $app_name --resource-group $resource_group_name --docker-custom-image-name codevault.azurecr.us/codeserver:v1 --docker-registry-server-url codevault.azurecr.us --docker-registry-server-user $APP_ID --docker-registry-server-password $SP_PASSWD
az webapp config set --resource-group $resource_group_name --name $app_name --startup-file="docker run -d --name=code-server   -e PUID=1000   -e PGID=1000   -e TZ=Etc/UTC -e DEFAULT_WORKSPACE=/config/workspace `#optional`   -p 443:443   -v /path/to/appdata/config:/config   --restart unless-stopped  codevault.azurecr.us/codeserver:v1"
az webapp restart --name $app_name --resource-group $resource_group_name

#docker run -d --name=code-server   -e PUID=1000   -e PGID=1000   -e TZ=Etc/UTC -e DEFAULT_WORKSPACE=/config/workspace `#optional`   -p 443:443   -v /path/to/appdata/config:/config   --restart unless-stopped  codevault.azurecr.us/codeserver:v1