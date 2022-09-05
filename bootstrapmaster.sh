echo "Edit /usr/lib/systemd/system/docker.service
Modify this line
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
To
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd

Restart the Docker service by running the following command:

systemctl daemon-reload
systemctl restart docker"

echo "[TASK] Cleanup containerd config"
rm /etc/containerd/config.toml
systemctl restart containerd

echo "[TASK] Initialize Kubernetes

kubeadm init --control-plane-endpoint="172.16.16.100:6443" --upload-certs --apiserver-advertise-address=172.16.16.101 --pod-network-cidr=192.168.0.0/16

echo "[TASK]Deploying Calico Network for K8S"

curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/calico.yaml -O

kubectl apply -f calico.yaml
