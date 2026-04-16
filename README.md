# jagatku

## Requirements
1. Runs on Apple silicon macos
2. Install kubectl: `brew install kubectl`
3. Install vagrant: `brew install vagrant`
4. Install virtualbox: https://www.virtualbox.org/wiki/Downloads
5. Install ansible: `brew install ansible`

## Initial setup
1. Start vagrant machines: `vagrant up`
2. Initialize K3s cluster: `ansible-playbook init-k3s-cluster.yml`

## K3s Cluster Setup

This repository includes Ansible automation to initialize a K3s Kubernetes cluster.

### Cluster Architecture
- **node1** (192.168.54.11): K3s server (control plane)
- **node2** (192.168.54.12): K3s agent (worker)
- **node3** (192.168.54.13): K3s agent (worker)

### Files Structure
```
├── ansible.cfg              # Ansible configuration
├── inventory.yaml           # Ansible inventory with cluster nodes
├── init-k3s-cluster.yml     # Main playbook for K3s initialization
├── roles/
│   ├── k3s_server/         # Role for K3s server installation
│   │   └── tasks/
│   │       └── main.yml
│   └── k3s_agent/           # Role for K3s agent installation
│       └── tasks/
│           └── main.yml
└── cluster-provisioning.yaml # Additional cluster components
```

### Usage
```bash
# Initialize the K3s cluster
ansible-playbook init-k3s-cluster.yml

# Install additional components (monitoring, ingress, etc.)
ansible-playbook cluster-provisioning.yaml
```

### Verification
```bash
# SSH into the server node
vagrant ssh node1

# Check cluster status
kubectl get nodes
kubectl cluster-info
```

## Errors
### undefined method `exists`?
This error happen when using virtualbox version `7.2.6`
```shell
==> default: Attempting graceful shutdown of VM...
==> default: Destroying VM and associated drives...
/usr/share/vagrant/gems/gems/vagrant-vbguest-0.32.0/lib/vagrant-vbguest/hosts/virtualbox.rb:84:in `block in guess_local_iso': undefined method `exists?' for class File (NoMethodError)

path && File.exists?(path)
^^^^^^^^
```
Detail discussion can be found in https://github.com/hashicorp/vagrant/issues/13404, the solution is to use forked plugin repo in https://github.com/dheerapat/vagrant-vbguest?tab=readme-ov-file#vagrant-vbguest
