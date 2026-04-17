#!/bin/bash
sudo apt update
sudo apt install -y python3-pip python3-kubernetes

# Specify the version to install
VERSION="v3.20.2"
OS="linux"
ARCH="arm64"

# Download the tarball from official releases
wget https://get.helm.sh/helm-${VERSION}-${OS}-${ARCH}.tar.gz

# Unpack the binary
tar -zxvf helm-${VERSION}-${OS}-${ARCH}.tar.gz

# Move binary to system path
sudo mv ${OS}-${ARCH}/helm /usr/local/bin/helm

# Verify installation
helm version
