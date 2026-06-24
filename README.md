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

kubectl create secret generic vault-token \
  -n external-secrets \
  --from-literal=token="<VAULT_TOKEN>"

kubectl apply -f aws/external-secrets/vault-backend.yaml


## deploy my-app using ArgoCD
kubectl create namespace my-app
kubectl apply -f argocd/my-app.yaml


### 🏗️ System Architecture & GitOps Workflow

```mermaid
flowchart TB
    %% --- STYLING MACROS ---
    classDef ci font-weight:bold,fill:#f6f8fa,stroke:#d0d7de,stroke-width:2px;
    classDef aws font-weight:bold,fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:white;
    classDef eks font-weight:bold,fill:#326CE5,stroke:#1f4da1,stroke-width:2px,color:white;
    classDef tool font-weight:bold,fill:#8A2BE2,stroke:#4B0082,stroke-width:2px,color:white;
    classDef user font-weight:bold,fill:#2ecc71,stroke:#27ae60,stroke-width:2px,color:white;

    %% --- SUBGRAPH: CI/CD & SOURCE ---
    subgraph CI_CD ["📦 DevOps Pipeline (GitOps)"]
        Dev["👨‍💻 Developer"]
        GitHub["🐙 GitHub Repo\n(Source & Helm)"]
        GHA["⚙️ GitHub Actions"]
        
        Dev -->|Push / Release| GitHub
        GitHub -->|Trigger Workflow| GHA
    end
    class GitHub,GHA ci; class Dev user;

    %% --- SUBGRAPH: AWS INFRASTRUCTURE ---
    subgraph AWS ["☁️ Amazon Web Services"]
        VPC["🌐 AWS VPC"]
        ECR["📦 Amazon ECR"]
        ALB["🎯 AWS ALB"]
        Aurora["🗄️ Aurora PostgreSQL"]
        
        %% --- SUBGRAPH: EKS CLUSTER ---
        subgraph EKS_Cluster ["☸️ EKS Kubernetes Cluster"]
            ArgoCD["🐙 Argo CD\n(GitOps Controller)"]
            ALBController["🔧 AWS LB Controller"]
            
            subgraph App_Stack ["🚀 Application Stack"]
                Ingress["🛣️ K8s Ingress"]
                Service["🔌 K8s Service"]
                Deployment["📦 K8s Deployment"]
                ExtSecret["🔑 External Secrets"]
            end
        end
    end
    class AWS,VPC,ECR,ALB,Aurora aws;
    class EKS_Cluster,ArgoCD,ALBController,Ingress,Service,Deployment,ExtSecret eks;

    %% --- OUTSIDE TOOLS ---
    Terraform["🏗️ Terraform (IaC)"]
    Vault["🔒 HashiCorp Vault"]
    User["🌐 Internet User"]
    class Terraform,Vault tool; class User user;

    %% --- INFRASTRUCTURE PROVISIONING (TERRAFORM) ---
    Terraform ----> VPC
    Terraform ----> EKS_Cluster
    Terraform ----> Aurora
    Terraform ----> Vault
    Terraform -->|Deploy via Helm/Manifest| ArgoCD
    Terraform -->|Deploy| ALBController

    %% --- CI/CD FLOW ---
    GHA -->|1. Build & Push Image| ECR
    GHA -->|2. Update Tag values.yaml| GitHub
    GitHub -->|3. Auto Sync| ArgoCD
    ArgoCD -->|4. Deploy Manifests| Deployment

    %% --- TRAFFIC FLOW ---
    User -->|HTTP/HTTPS| ALB
    ALBController <-->|Manage| ALB
    ALB --> Ingress
    Ingress --> Service
    Service --> Deployment

    %% --- DATA & SECURITY FLOW ---
    Deployment --> ExtSecret
    ExtSecret -->|Fetch Secrets| Vault
    Deployment -->|Database Connection| Aurora