# Infrastructure

## About
Infrastructure is a tool to manage infrastructure and IAM roles to help CTOs and developers.

## usage
- `source <(setkubeconfig {COMPANY} {ENVIRONMENT})`
- `infra template -vv devops-target`
- init sequence
    - (optional) `infra sts -vv assume-role`
    - `infra vpc -vv vpc-create`
    - `infra fargate -vv create-role`
    - `infra deployer -vv terraform-eks-deploy-role`
    - `infra eks -vv create-cluster`
    - `infra oidc -vv associate-iam-oidc-provider`
    - `infra albic -vv create-iam-service-account deploy`
    - `infra nxic -vv deploy`
    - `infra ddsa -vv create-iam-service-account deploy`
- destroy sequence
    - `infra ddsa -vv delete delete-iam-service-account`
    - `infra nxic -vv delete`
    - `infra albic -vv delete delete-iam-service-account` 
    - `infra eks -vv delete-cluster`
    - `infra deployer -vv terraform-eks-destroy-role`
    - `infra fargate -vv delete-role`
    - `infra vpc -vv vpc-destroy`


creazione del certifoicato eksctl
    - `infra kubeconfig -vv kubeconfig`
