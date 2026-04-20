#!/bin/bash

# install ALB ingress controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
--set clusterName=my-eks-cluster

# MySQL operator
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm repo update
helm install mysql-operator mysql-operator/mysql-operator --namespace mysql-operator --create-namespace

# deploy app layer
kubectl apply -f services.yaml

# deploy app
kubectl apply -f deploy.yaml