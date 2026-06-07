#! /bin/bash

# Disable swap memory permanently
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a