Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo Hello"

  config.vm.define "node1" do |node|
    node.vm.box = "cloud-image/ubuntu-24.04"
  end

  config.vm.define "node2" do |node|
    node.vm.box = "cloud-image/ubuntu-24.04"
  end
end
