#!/bin/bash

# ==============================================================
# Edit your /etc/hosts file to resolve IP and FQDN. 
# Pre-requisite steps: disable swap
#                      disable firewall (demo only)
# Install packages:    Helm
#
# Install Docker
# Install Docker Compose
# Update Docker daemon 
#
# 29/05/2022
# ==============================================================

# Infrastructure
dnf update -y
dnf upgrade -y
dnf install epel-release -y
swapoff --all
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
systemctl disable firewalld # Do not disable in Production.
cp /etc/sysctl.conf /etc/sysctl.conf.bak # Elasticsearch requires a max map count > 262144
chown -R $(id -u) /etc/sysctl.conf
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p --system
echo -e "Infrastructure update completed .."

sleep 3s
echo -e "Install Pre-requisites .."

# Yq Jq and Helm are no longer required as installed pre-requisite packages for Foundry. 
# Foundry scripts are executed within a specific foundry_install_control_plane pod which has
# the required installed packages. 
# The packages are installed as they're required to execute other scripts.

# Install Yq
snap install yq
sleep 2s
echo -e "Yq installed .."

# Install Jq 
dnf install -y jq
sleep 2s
echo -e "Jq installed .."

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
sleep 2s
echo -e "Helm installed .."
sleep 2s
echo -e "Pre-requisite installations completed .."

# Docker pre-requisites
sleep 3s
echo -e "Install Docker .."
dnf remove -y docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-selinux \
                docker-engine-selinux \
                docker-engine \
                podman \
                runc
dnf install -y yum-utils bash-completion dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf makecache
sleep 2s
dnf list docker-ce
sleep 5s
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl start docker
systemctl enable docker
groupadd docker
usermod -aG docker $USER
systemctl restart docker
sleep 3s
echo -e "Docker installed .."


# Install Latest Docker Compose
sleep 3s
echo -e "Install Docker Compose .."
dnf install curl wget -y
curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
chmod +x docker-compose-linux-x86_64
mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Update Docker Daemon for Insecure Registry
tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries" : ["foundry.skytap.example:5000","0.0.0.0/0"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },

  "storage-driver": "overlay2"
}
EOF
systemctl restart docker.service
sleep 1s
echo -e "Docker daemon updated .."
sleep 3s
echo -e "Reboot required .."
sleep 3s
reboot