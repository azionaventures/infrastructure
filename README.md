# Infrastructure

## About
Infrastructure is a tool to manage cloud infrastructure and IAM roles to support tech teams.

## Requirements
- install azionacli
- install helm

## Install req.

    # 1. Install aziona tools

    git clone https://github.com/azionaventures/workstation-setup.git
    cd workstation-setup
    make setup

    # 2. Install HELM

      # ubuntu 
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    
      # mac
    brew install helm
    
    # 3. Add helm repo
    helm repo add hkube http://hkube.io/helm/

## usage

1. Creazione repository tenant-settings. La repo deve contenere una o più cartelle, che contengono ognuna il proprio file .env
2. Creazione bucket S3
3. Creazione Certificato SSL (per nginx ingress controll)
4. Creazione table Dynamo DB
    nome: terraform-lock
    partizione: LockID
5. Eseguire i comandi sequenzialmente:
- `source aziona-activate -e ENV -c COMAPNY --aws-profile AWS_PROFILE --env-only`
- `export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile AWS_PROFILE)`
- `export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile AWS_PROFILE)`
- `export AZIONA_WORKSPACE_INFRASTRUCTURE=$(pwd)`
- init sequence
    - `aziona-infra sts assume-role` (optional) Assumi il ruolo che ha la seguente Policy ...  
    - `aziona-infra -t vpc vpc-create` (req.) Crea la VPC per la gestione del cluster Multi-AZ.
    - `aziona-infra -t fargate create-role` (req.) Crea il ruolo fargate con la policy (default aws) AmazonEKSFargatePodExecutionRolePolicy
    - `aziona-infra -t deployer terraform-eks-deploy-role` (req.) Crea il ruolo per accedere al cluster (utilizzabile da terminale o per eseguire le pipeline di deploy)
    - `aziona-infra -t eks create-cluster kubeconfig` (req.) Crea il cluster di eks e i profili associandogli i ruoli fargate (creati in precedenza), e successivamente, crea il certificato per accedere al cluster
    - `aziona-infra -t oidc associate-iam-oidc-provider` (req.) Crea il bridge tra il cluster eks e le API di aws
    - `aziona-infra -t albic create-iam-service-account deploy` (req.) Crea la policy nel service account che consentirà al ALB Controller di creare gli ALB su AWS per ogni ingress (deployato nel cluster e che richiede un ALB). Successivamente effettua il deploy del pod ALB Controller sul cluster (nel namespace kube-system)
    - `aziona-infra -t nxic deploy` (req.) Crea l'nginx ingress controller e il nginx backend (il load balancer). Ogni volta che viene aggiunto un ingress di con annotation nginx al cluster l'nginx ingress controller aggiorna l'nginx backend. 
    - `aziona-infra -t ddsa create-iam-service-account deploy` (req.) Crea il service account per effettuare lo stream delle metriche del cluster a datadog. Successivamente effettua il deploy di un pod chiamato metrics-server che serve per raccogliere le metriche dei pod e container presenti sul cluster
- destroy sequence
    - `aziona-infra -t ddsa delete delete-iam-service-account`
    - `aziona-infra -t nxic delete`
    - `aziona-infra -t albic delete delete-iam-service-account` 
    - `aziona-infra -t eks delete-cluster`
    - `aziona-infra -t deployer terraform-eks-destroy-role`
    - `aziona-infra -t fargate delete-role`
    - `aziona-infra -t vpc vpc-destroy`


creazione del certifoicato eksctl
    - `aziona-infra kubeconfig`
