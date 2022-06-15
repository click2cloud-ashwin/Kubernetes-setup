#!/bin/bash

echo Setup: Install basic dependencies
sudo apt-get install -y -q \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo Setup: Docker

sudo apt-get update
sudo apt-get install -y -q docker.io

cat <<EOF | sudo tee /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2"
}
EOF

sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl daemon-reload


echo Setup: Install Kubernetes

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && sudo apt-get update

sudo apt install  -y -q \
	kubeadm=1.21.6-00 \
	kubelet=1.21.6-00 \
	kubectl=1.21.6-00 \
	kubernetes-cni \
	&& sudo apt-mark hold kubeadm kubelet kubectl

echo Setup: Basic

sudo systemctl stop ufw
sudo systemctl disable ufw
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo partprobe
sudo echo "vm.swappiness=0" | sudo tee --append /etc/sysctl.conf
sudo sysctl -p
IP_ADDR=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)
sudo sed -i '2s/.*/'$IP_ADDR' '$HOSTNAME'/' /etc/hosts
sudo rm -rf /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

sudo apt autoremove -y

echo Setup: Machine setup completed!

sudo reboot
