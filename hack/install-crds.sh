#!/bin/bash
set -e

kubectl apply -f https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/cluster-api-crds.yaml
kubectl apply -f https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/bootstrap-kubeadm-crds.yaml
kubectl apply -f https://github.com/kubernetes-sigs/cluster-api/releases/latest/download/control-plane-kubeadm-crds.yaml
kubectl apply -f https://github.com/kubernetes-sigs/cluster-api-provider-vsphere/releases/latest/download/infrastructure-components.yaml
