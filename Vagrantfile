Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo Hello"

  config.vm.define "node1" do |node|
    node.vm.box = "cloud-image/ubuntu-24.04"
    node.vm.box_version = "20260323.0.0"
    node.vm.provider "qemu" do |qe|
      qe.memory = "4G"
      qe.ssh_port = 50023
    end
  end

  config.vm.define "node2" do |node|
    node.vm.box = "cloud-image/ubuntu-24.04"
    node.vm.box_version = "20260323.0.0"
    node.vm.provider "qemu" do |qe|
      qe.memory = "4G"
      qe.ssh_port = 50024
    end
  end
end
