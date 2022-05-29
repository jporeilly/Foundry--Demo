#!/bin/bash

# ==============================================================
#
# Deploy k3s -disable traefik
# Configure kubectl 
#
# 29/05/2022
# ==============================================================

# Install k3s - Rancher
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.21.12+k3s1 sh -

# Connect and test kubectl
sudo mkdir ~/.kube
sudo chown -R k8s /etc/rancher/k3s
sudo cp -i /etc/rancher/k3s/k3s.yaml  $HOME/.kube/config
sudo chown -R  $(id -u):$(id -g) $HOME/.kube/
systemctl enable k3s
sleep 5s
kubectl get nodes # note kubernetes version
sleep 10s
echo -e "k3s Installation Completed .."

sleep 5s
echo -e "Reboot required .."
reboot