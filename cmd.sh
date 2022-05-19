# https://github.com/cert-manager/cert-manager/issues/3237
# https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

eksctl utils associate-iam-oidc-provider \
    --region eu-central-1 \
    --cluster jobtech-staging-1-22 \
    --approve
    
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document policy/alb-iam-policy-v2.json

eksctl create iamserviceaccount \
  --cluster=jobtech-staging-1-22 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name "AmazonEKSLoadBalancerControllerRole" \
  --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# ADDON https://docs.aws.amazon.com/eks/latest/userguide/service-accounts.html#boundserviceaccounttoken-validated-add-on-versions

eksctl create addon \
    --name vpc-cni \
    --version v1.11.0-eksbuild.1 \
    --cluster jobtech-staging-1-22 \
    --service-account-role-arn arn:aws:iam::111122223333:role/AmazonEKSVPCCNIRole \
    --force

eksctl create addon --name coredns --cluster jobtech-staging-1-22 --force

eksctl create addon --name kube-proxy --cluster jobtech-staging-1-22 --force

eksctl get addon --cluster jobtech-staging-1-22

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=jobtech-staging-1-22 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller  \
  --set vpcId=vpc-0b74e548ecb03168e \
  --set region=eu-central-1



# ------

source neulabs-activate -e staging-1-22 -c jobtech --aws-profile jobtech --without-cert
jt-eks-sta
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile jobtech)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile jobtech)

 kubectl get pods -n kube-system
 kubectl logs PODNAME -n kube-system
 kubectl describe pod PODNAME -n kube-system
 kubectl delete deployment aws-load-balancer-controller -n kube-system
 