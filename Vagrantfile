Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "sudo apt update"

  config.vm.define "node1" do |node|
    node.vm.box = "cloud-image/ubuntu-24.04"
    node.vm.provider "virtualbox" do |v|
      v.memory = 4196
      v.cpus = 2
    end
  end

  config.vm.define "node2" do |node|
    node.vm.box = "cloud-image/ubuntu-24.04"
    node.vm.provider "virtualbox" do |v|
      v.memory = 4196
      v.cpus = 2
    end
  end

  config.vm.define "node3" do |node|
    node.vm.box = "cloud-image/ubuntu-24.04"
    node.vm.provider "virtualbox" do |v|
      v.memory = 4196
      v.cpus = 2
    end
  end
end
2