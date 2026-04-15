# jagatku

## Requirements
1. Runs on Apple silicon macos
2. Install kubectl: `brew install kubectl`
3. Install colima: `brew install colima`
4. Install k3d: `curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash`

## Initial setup
1. Start colima docker server: `colima start`
2. Start kubernetes cluster: `k3d cluster create jagad --registry-create jagad-reg:5000`
2. Provision cluster: `ansible-playbook cluster-provisioning.yaml`
