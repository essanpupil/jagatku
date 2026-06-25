Vagrant.configure("2") do |config|
  config.vm.define "node1" do |node|
    node.vm.box = "cloud-image/debian-13"
    node.vm.box_version = "20260623.2518.0"
    node.vm.network "public_network", ip: "192.168.1.12"
    node.vm.hostname = "node1"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
  end

  config.vm.define "node2" do |node|
    node.vm.box = "cloud-image/debian-13"
    node.vm.box_version = "20260623.2518.0"
    node.vm.network "public_network", ip: "192.168.1.13"
    node.vm.hostname = "node2"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
  end

  config.vm.define "node3" do |node|
    node.vm.box = "cloud-image/debian-13"
    node.vm.box_version = "20260623.2518.0"
    node.vm.network "public_network", ip: "192.168.1.14"
    node.vm.hostname = "node3"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
  end
end
