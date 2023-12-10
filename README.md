# test-ingress
built to test ingress control in kubernetes

## commands
docker build -t test_ingress .
docker run -d -p 8080:80 test_ingress
curl http://localhost:8080/

## install kind
```bash
sudo snap install go --classic
mkdir ~/kind-install
cd ~/kind-install
go mod init tempmod
go get sigs.k8s.io/kind@v0.20.0
#verify
~/go/bin/kind version
sudo ln -s ~/go/bin/kind /usr/local/bin/kind
```
## Kind cmds
```bash
## list all clusters
kind get clusters
## spin up cluster
kind create cluster --name <cluster-name> --image kindest/node:v1.23.5
## remove cluster
kind delete cluster --name <cluster-name>
```


## create kubernetes cluster
```bash
## spin up cluster
kind create cluster --name ingress --image kindest/node:v1.23.5
# context

## verify cluster up and running
kubectl get nodes
NAME                  STATUS   ROLES                  AGE     VERSION
nginx-ingress-control-plane   Ready    control-plane,master   2m12s   v1.23.5

## Run a container to work in 

### run alpine linux
```bash
docker run -it -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh
```

### install tools
```bash
# install curl 
apk add --no-cache curl

# install kubectl 
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# install helm 

curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
tar -C /tmp/ -zxvf /tmp/helm.tar.gz
mv /tmp/linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm

# install vim
apk add vim
```

### create helm manifest
```bash
CHART_VERSION="4.4.0"
APP_VERSION="1.5.1"

mkdir ./kubernetes/ingress/controller/nginx/manifests/

helm template ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--version ${CHART_VERSION} \
--namespace ingress-nginx \
> ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml
```

### Check Helm Manifest
```bash
vim ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.1.5.1.yaml
```
### Deploy ingress controller
```bash
kubectl create namespace ingress-nginx
kubectl apply -f ./kubernetes/ingress/controller/nginx/manifests/nginx-ingress.${APP_VERSION}.yaml
```

### Check the installation
```bash
kubectl -n ingress-nginx get pods
```
#### Example
```bash
/work # kubectl -n ingress-nginx get pods
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-qr59j        0/1     Completed   0          62s
ingress-nginx-admission-patch-tsdmk         0/1     Completed   1          62s
ingress-nginx-controller-7d5fb757db-r8pg6   1/1     Running     0          62s
# all ingress objects will access pods th through ingress controller service
# to view service
/work # kubectl -n ingress-nginx get svc
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.183.90    <pending>     80:30756/TCP,443:30873/TCP   5m31s
ingress-nginx-controller-admission   ClusterIP      10.96.124.248   <none>        443/TCP                      5m31s
```

### Example: Test-Ingress

```bash

git clone https://github.com/michavardy/test-ingress.git ./kubernetes/services/
kubectl apply -f ./kubernetes/services/test-ingress/K8s/config.yaml
```

### Initial Test
```bash
# setup up port forwarding from 443 to svc/ingress-nginx-controller
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 443
# port forward
kubectl port-forward svc/test-ingress 80
```
```