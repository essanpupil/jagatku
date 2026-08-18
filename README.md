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
2. Prometheus node exporter configuration for node metrics monitoring.  
   `$ ansible-playbook playbooks/virtual-machines/prometheus/prometheus-node-exporter-config.yaml`
3. Alloy for logging agent.  
   `$ ansible-playbook playbooks/virtual-machines/alloy/alloy-configuration.yaml`
4. Update prometheus configuration.  
   `$ ansible-playbook playbooks/baremetals/prometheus/configuration.yaml`

## Kubernetes Deployment
Kubernetes cluster is deployed using `kubeadm` without kube-proxy disabled.
This is because the functionality of kube-proxy will be handled by Cilium.
