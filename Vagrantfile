Vagrant.configure("2") do |config|
  config.vm.provision "shell", path: "k8s-node-provisioning.sh"

  config.vm.define "node1" do |node|
    node.vm.box = "bento/ubuntu-26.04"
    # node.vm.network "private_network", ip: "192.168.54.11"
    node.vm.network "public_network", bridge: "en0: Wi-Fi"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
  end

  # config.vm.define "node2" do |node|
  #   node.vm.box = "bento/ubuntu-24.04"
  #   node.vm.network "private_network", ip: "192.168.54.12"
  #   node.vm.network "public_network", bridge: "en0: Wi-Fi"
  #   node.vm.disk :disk, size: "30GB", primary: true
  #   node.vm.provider "virtualbox" do |v|
  #     v.memory = 6144
  #     v.cpus = 2
  #   end
  # end

  # config.vm.define "node3" do |node|
  #   node.vm.box = "bento/ubuntu-24.04"
  #   node.vm.network "private_network", ip: "192.168.54.13"
  #   node.vm.network "public_network", bridge: "en0: Wi-Fi"
  #   node.vm.disk :disk, size: "30GB", primary: true
  #   node.vm.provider "virtualbox" do |v|
  #     v.memory = 6144
  #     v.cpus = 2
  #   end
  # end
end
