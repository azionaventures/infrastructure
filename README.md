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
    
## usage

1. Create tenant-settings repository. The repo must contain one or more folders, each containing its own .env file
2. S3 bucket creation
3. SSL Certificate creation (for nginx ingress controll)
4. Dynamo DB table creation
    name: terraform-lock
    partition: LockID
5. Run the commands sequentially:
- `source neulabs-activate -e ENV -c COMAPNY --aws-profile AWS_PROFILE --without-cert`
- `export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile AWS_PROFILE)`
- `export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile AWS_PROFILE)`
- init sequence
    - `neulabs infra sts assume-role` (optional) Assume the role that has the following Policy ...  
    - `neulabs infra -t vpc vpc-create` (req.) Creates the VPC for managing the Multi-AZ cluster.
    - `neulabs infra -t fargate create-role` (req.) Creates the fargate role with policy (default aws) AmazonEKSFargatePodExecutionRolePolicy
    - `neulabs infra -t deployer terraform-eks-deploy-role` (req.) Creates the role to access the cluster (usable from terminal or to run deployment pipelines)
    - `neulabs infra -t eks create-cluster kubeconfig` (req.) Creates the eks cluster and profiles by associating the fargate roles (created earlier), and then, creates the certificate to access the cluster
    - `neulabs infra -t oidc associate-iam-oidc-provider` (req.) Creates the bridge between the eks cluster and the aws API
    - `neulabs infra -t albic create-iam-service-account create-addo deploy` (req.) Creates the policy in the service account that will allow the ALB Controller to create ALBs on AWS for each ingress (deployed to the cluster and requiring an ALB). It then deploys the ALB Controller pod to the cluster (in the kube-system namespace)
    - `neulabs infra -t nxic deploy` (req.) Creates the nginx ingress controller and the nginx backend (the load balancer). Whenever an ingress of with nginx annotation is added to the cluster the nginx ingress controller updates the nginx backend. 
    - `neulabs infra -t ddsa create-iam-service-account deploy` (req.) Creates the service account to stream cluster metrics to datadog. It then deploys a pod called metrics-server which is used to collect metrics from pods and containers on the cluster.
- destroy sequence
    - `neulabs infra -t ddsa delete delete-iam-service-account`
    - `neulabs infra -t nxic delete`
    - `neulabs infra -t albic delete delete-iam-service-account` 
    - `neulabs infra -t eks delete-cluster`
    - `neulabs infra -t deployer terraform-eks-destroy-role`
    - `neulabs infra -t fargate delete-role`
    - `neulabs infra -t vpc vpc-destroy`



eksctl create iamidentitymapping --cluster jobtech-staging-1-22 --arn arn:aws:iam::039794779361:user/fabrizio.cafolla.jobtech --group system:masters --username fabrizio.cafolla.jobtech

eksctl create iamidentitymapping --cluster jobtech-staging-1-22 --region eu-central-1 --arn arn:aws:iam::039794779361:user/giacomo.petrucci --group system:masters --username giacomo.petrucci

eksctl create iamidentitymapping --cluster jobtech-staging-1-22 --arn arn:aws:iam::039794779361:role/eks-console-staging --group system:masters --username eks-console-staging

eksctl create iamidentitymapping --cluster jobtech-staging-1-22 --arn arn:aws:iam::039794779361:role/eks-deployer-role-staging-1-22 --group system:masters --username eks-deployer-role-staging-1-22

eksctl get iamidentitymapping --cluster jobtech-staging-1-22 --region eu-central-1

kubectl get -n kube-system configmap/aws-auth -o yaml