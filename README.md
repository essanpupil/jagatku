# jagatku
Store various proof of concept for SRE, DevOps and Platform Engineering.

## Start Up
To activate the system, follow the guide below
1. Clone this repo.  
   `$ git clone https://github.com/essanpupil/jagatku.git`
2. Go to repo directory:  
   `$ cd jagatku`
3. Edit `Vagrantfile` as necessary.
4. Edit `inventory.yaml` aligned with `Vagrantfile`.
5. Start up virtual servers:  
   `$ vagrant up`

## Virtual Machine Configuration
Run ansible playbooks with the following order to configure virtual machines for kubernetes.
1. Virtual machine common configuration.  
   `$ ansible-playbook playbooks/virtual-machines/virtual-machine/configurations.yaml`
2. Update server `/etc/hosts` config for private domain name.  
   `$ ansible-playbook playbooks/baremetals/etc-hosts/configuration.yaml`
3. Prometheus node exporter configuration for node metrics monitoring.  
   `$ ansible-playbook playbooks/virtual-machines/prometheus/prometheus-node-exporter-config.yaml`
4. Alloy for logging agent.  
   `$ ansible-playbook playbooks/virtual-machines/alloy/alloy-configuration.yaml`
5. Update prometheus configuration.  
   `$ ansible-playbook playbooks/baremetals/prometheus/configuration.yaml`

## Kubernetes Core Deployment
Kubernetes cluster is deployed using `kubeadm` without kube-proxy.
This is because the functionality of kube-proxy will be handled by Cilium.
1. Initiate kubeadm.  
   `$ ansible-playbook playbooks/kubernetes/kubeadm-cp/cluster-init.yaml`
2. Update nginx upstream kube-apiserver in baremetal.  
   `$ ansible-playbook playbooks/baremetals/nginx/configuration.yaml`
3. Install and join kubeadm node.  
   `$ ansible-playbook playbooks/baremetals/etc-hosts/configuration.yaml`
4. Update kubernetes nameserver IP address.  
   `$ ansible-playbook playbooks/kubernetes/kubernetes-core/configurations.yaml`
5. Install Cilium Kubernetes CNI addon.
   ```shell
   $ cd terraform-configs/kubernetes/cillium/
   $ terraform init  # Initiate terraform providers
   $ terraform plan  # Check for any unexpected planning, then fix as needed
   $ terrafrom apply # Apply terraform config of cilium helm release
   ```
6. Make sure kube-proxy removal and kube node os config.  
   `$ ansible-playbook playbooks/kubernetes/remove-kube-proxy/playbook.yaml`

## Kubernetes Advance Configuration
1. Install MetalLB
   ```shell
   $ cd terraform-configs/kubernetes/metallb/
   $ terraform init  # Initiate terraform providers
   $ terraform plan  # Check for any unexpected planning, then fix as needed
   $ terrafrom apply # Apply terraform config of cilium helm release
   ```
