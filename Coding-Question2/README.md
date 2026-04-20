# AWS EKS and k8s service sample

> Note: these are still prototype because it didn't be tested.<br>
>       And IAM roles, security groups are not ready.

## Steps
1. run terraform
```
terraform init
terraform plan
terraform apply
```
2. install additional packages into k8s, then deploy apps
```
cd k8s
. init.sh
```

## Components
- infra layer, created by terraform
    - AWS infra
    - EKS control plane + basic addons
    - EKS managed node group
    - ALB, ingress class
    - EBS storage class
    - (TODO) IAM roles
    - (TODO) K8S RBAC

- DB layer
    - use MySQL operator directly<br>
      https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-introduction.html

- K8S
    - AWS ingress controller (Will be integrated into infra layer after AWS EKS addon ready)

- APP layer. Between app and infra, needs to managed by admin
    - service
    - ingress
    - service account
    - (TODO) IAM role for service
    - (TODO) network policy

- APP
    - deployments

