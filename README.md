# Infrastructure

## About
Infrastructure is a tool to manage cloud infrastructure and IAM roles to support tech teams.

## requirements
- install azionacli
- install helm
- helm repo add hkube http://hkube.io/helm/

## usage

1. Creazione repository tenant-settings
2. Creazione bucket S3
3. Creazione Certificato SSL (per nginx ingress controll)
4. Creazione table Dynamo DB
    nome: terraform-lock
    partizione: LockID

- `source aziona-activate -e ENV -c COMAPNY --aws-profile AWS_PROFILE --env-only`
- `export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile AWS_PROFILE)`
- `export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile AWS_PROFILE)`
- `export INFRASTRUCTURE_PATH=...`
- init sequence
    - (optional) `aziona-infra sts assume-role`
    - `aziona-infra -t vpc vpc-create`
    - `aziona-infra -t fargate create-role`
    - `aziona-infra -t deployer terraform-eks-deploy-role`
    - `aziona-infra -t eks create-cluster`
    - `aziona-infra -t oidc associate-iam-oidc-provider`
    - `aziona-infra -t albic create-iam-service-account deploy`
    - `aziona-infra -t nxic deploy`
    - `aziona-infra -t ddsa create-iam-service-account deploy`
- destroy sequence
    - `aziona-infra ddsa delete delete-iam-service-account`
    - `aziona-infra nxic delete`
    - `aziona-infra albic delete delete-iam-service-account` 
    - `aziona-infra eks delete-cluster`
    - `aziona-infra deployer terraform-eks-destroy-role`
    - `aziona-infra fargate delete-role`
    - `aziona-infra vpc vpc-destroy`


creazione del certifoicato eksctl
    - `aziona-infra kubeconfig kubeconfig`
