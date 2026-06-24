# gitops-based-k8s

## terraform apply

cd terraform/environments/dev

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply --auto-approve


## connect to EKS Cluster

aws eks update-kubeconfig --region ap-southeast-1 --name eks-lab

kubectl get nodes

## Metrics Server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

kubectl get deployment -n kube-system | grep metrics-server
kubectl top node

## install ArgoCD

kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc -n argocd argocd-server -p '{"spec": {"type": "LoadBalancer"}}'

kubectl -n argocd get svc argocd-server

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

## install external-secrets

helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets \
  -n external-secrets \
  --create-namespace


## deploy my-app using ArgoCD
kubectl create namespace my-app
kubectl apply -f argocd/my-app.yaml