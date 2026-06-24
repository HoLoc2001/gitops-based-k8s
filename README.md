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


flowchart TD
    Dev[Developer] --> GitLab[GitLab Repository]

    GitLab --> CI[GitLab CI/CD]
    CI --> Docker[Build Docker Image]
    Docker --> ECR[AWS ECR]

    GitLab --> Terraform[Terraform]
    Terraform --> VPC[AWS VPC]
    Terraform --> EKS[AWS EKS Cluster]
    Terraform --> Aurora[Aurora PostgreSQL]
    Terraform --> Vault[HashiCorp Vault]

    GitLab --> ArgoCD[Argo CD]

    ArgoCD --> Helm[Helm Chart]
    Helm --> App[Application Pods]

    EKS --> ALBController[AWS Load Balancer Controller]
    ALBController --> ALB[Application Load Balancer]

    User[User / Browser] --> ALB
    ALB --> Ingress[Kubernetes Ingress]
    Ingress --> Service[Kubernetes Service]
    Service --> App

    App --> Secret[ExternalSecret]
    Secret --> Vault
    Vault --> AuroraSecret[Aurora DB Credentials]
    App --> Aurora

    App --> Logs[Application Logs]
    Logs --> Loki[Loki]
    Loki --> Grafana[Grafana Dashboard & Alerts]

    subgraph AWS[AWS Cloud]
        VPC
        EKS
        Aurora
        ECR
        ALB
    end

    subgraph Kubernetes[EKS Kubernetes Cluster]
        ArgoCD
        ALBController
        Ingress
        Service
        App
        Secret
        Loki
        Grafana
    end

flowchart LR
    User[User / Browser] --> ALB[Application Load Balancer]
    ALB --> K8s[EKS Ingress Controller]
    K8s --> App[Application Pods]
    App --> Vault[Vault Agent Sidecar]
    Vault --> VaultAPI[Vault API]
    VaultAPI --> Secret[External Secrets Operator]
    Secret --> SecretStore[AWS Secrets Manager]
    App --> DB[PostgreSQL]
    DB --> DBSubnet[DB Subnet]
    ALB --> PublicSubnet[Public Subnet]
    App --> AppSubnet[Private App Subnet]
    Vault --> VaultSubnet[Vault Subnet]

    style User fill:#f9f,stroke:#333,stroke-width:2px
    style ALB fill:#ff9,stroke:#333,stroke-width:2px
    style K8s fill:#9cf,stroke:#333,stroke-width:2px
    style App fill:#9f9,stroke:#333,stroke-width:2px
    style Vault fill:#f9f,stroke:#333,stroke-width:2px
    style VaultAPI fill:#ffc,stroke:#333,stroke-width:2px
    style Secret fill:#cfc,stroke:#333,stroke-width:2px
    style SecretStore fill:#fcc,stroke:#333,stroke-width:2px
    style DB fill:#ccf,stroke:#333,stroke-width:2px
    style DBSubnet fill:#ddd,stroke:#333,stroke-width:2px
    style PublicSubnet fill:#ddd,stroke:#333,stroke-width:2px
    style AppSubnet fill:#ddd,stroke:#333,stroke-width:2px
    style VaultSubnet fill:#ddd,stroke:#333,stroke-width:2px