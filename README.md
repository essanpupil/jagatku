# jagatku

## pre-commit requirements
```shell
$ brew install pre-commit terraform-docs terraform-linters/tap/tflint tfsec trivy checkov terrascan infracost tfupdate minamijoyo/hcledit/hcledit jq
```

## Baremetal Deployment
1. Install Debian Server on old laptop
2. install core packages and core repository: `ansible-playbook palybooks playbooks/baremetals/baremetal/00-baremetal-configuration.yaml`
3. Install Prometheus: `ansible-playbook playbooks/baremetals/prometheus/02-prometheus-configuration.yaml`
4. Install Loki: `ansible-playbook playbooks/baremetals/loki/01-loki-configuration.yaml`
5. Install GRafana: `ansible-playbook playbooks/baremetals/grafana/01-grafana-configuration.yaml`
6. Install Alloy: `ansible-playbook playbooks/baremetals/alloy/alloy-configuration.yaml`

## Server Deployment
1. Spin up virtual servers: `vagrant up`
2. Install minimum core packages and important repositories: `ansible-playbook playbooks/virtual-machines/virtual-machine/vm-configurations.yaml`
3. Initiate kubeadm kubernetes cluster: `ansible-playbook playbooks/virtual-machines/kubeadm/1-kubeadm-init.yaml`
4. Install Alloy: `ansible-playbook playbooks/virtual-machines/alloy/alloy-configuration.yaml`
5. Install Prometheus node exporter: `ansible-playbook playbooks/virtual-machines/prometheus/prometheus-node-exporter-config.yaml`

## Kubernetes Provisioning
1.
