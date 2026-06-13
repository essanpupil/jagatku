#! /bin/bash

# Disable swap memory permanently
sudo sed -i '/^\/swap.img/s/^/# /' /etc/fstab
sudo swapoff -a

# Load kubernetes kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl networking
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
