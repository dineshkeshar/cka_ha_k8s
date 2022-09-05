#!/bin/bash

echo "[TASK1] Disable Firewall"
ufw disable

echo "[TASK2] Disable swap"
swapoff -a; sed -i '/swap/d' /etc/fstab

echo "[TASK3] Update sysctl settings for Kubernetes networking"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "[TASK4] Install Docker Engine"
{
  apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update && apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io
}

echo "[TASK5] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.16.16.100   loadbalancer
172.16.16.101   kmaster1
172.16.16.102   kmaster2
172.16.16.201	kworker1
EOF

echo "--==Kubernetes Setup==--"
echo "[TASK6] Add Apt repository"
{
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
}

echo "[TASK7] Install Kubernetes components"
apt update && apt install -y kubeadm kubelet kubectl

echo "[TASK8] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK9] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
