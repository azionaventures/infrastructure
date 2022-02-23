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

1. Create tenant-settings repository. The repo must contain one or more folders, each containing its own .env file
2. S3 bucket creation
3. SSL Certificate creation (for nginx ingress controll)
4. Dynamo DB table creation
    name: terraform-lock
    partition: LockID
5. Run the commands sequentially:
- `source aziona-activate -e ENV -c COMAPNY --aws-profile AWS_PROFILE --env-only`
- `export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile AWS_PROFILE)`
- `export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile AWS_PROFILE)`
- `export AZIONA_WORKSPACE_INFRASTRUCTURE=$(pwd)`
- init sequence
    - `aziona-infra sts assume-role` (optional) Assume the role that has the following Policy ...  
    - `aziona-infra -t vpc vpc-create` (req.) Creates the VPC for managing the Multi-AZ cluster.
    - `aziona-infra -t fargate create-role` (req.) Creates the fargate role with policy (default aws) AmazonEKSFargatePodExecutionRolePolicy
    - `aziona-infra -t deployer terraform-eks-deploy-role` (req.) Creates the role to access the cluster (usable from terminal or to run deployment pipelines)
    - `aziona-infra -t eks create-cluster kubeconfig` (req.) Creates the eks cluster and profiles by associating the fargate roles (created earlier), and then, creates the certificate to access the cluster
    - `aziona-infra -t oidc associate-iam-oidc-provider` (req.) Creates the bridge between the eks cluster and the aws API
    - `aziona-infra -t albic create-iam-service-account deploy` (req.) Creates the policy in the service account that will allow the ALB Controller to create ALBs on AWS for each ingress (deployed to the cluster and requiring an ALB). It then deploys the ALB Controller pod to the cluster (in the kube-system namespace)
    - `aziona-infra -t nxic deploy` (req.) Creates the nginx ingress controller and the nginx backend (the load balancer). Whenever an ingress of with nginx annotation is added to the cluster the nginx ingress controller updates the nginx backend. 
    - `aziona-infra -t ddsa create-iam-service-account deploy` (req.) Creates the service account to stream cluster metrics to datadog. It then deploys a pod called metrics-server which is used to collect metrics from pods and containers on the cluster.
- destroy sequence
    - `aziona-infra -t ddsa delete delete-iam-service-account`
    - `aziona-infra -t nxic delete`
    - `aziona-infra -t albic delete delete-iam-service-account` 
    - `aziona-infra -t eks delete-cluster`
    - `aziona-infra -t deployer terraform-eks-destroy-role`
    - `aziona-infra -t fargate delete-role`
    - `aziona-infra -t vpc vpc-destroy`



eksctl-certificate creation
    - action-infra kubeconfig
