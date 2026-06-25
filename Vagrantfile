Vagrant.configure("2") do |config|
  config.vm.define "node1" do |node|
    node.vm.box = "cloud-image/debian-13"
    node.vm.box_version = "20260623.2518.0"
    node.vm.network "public_network", ip: "192.168.1.12"
    node.vm.hostname = "node1"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--pae", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.memory = 2048
    end
    ssh_pub_key = File.readlines("macbook_key.pub").first.strip
    node.vm.provision 'shell', inline: "echo '#{ssh_pub_key}' >> /home/vagrant/.ssh/authorized_keys", privileged: false
  end

  config.vm.define "node2" do |node|
    node.vm.box = "cloud-image/debian-13"
    node.vm.box_version = "20260623.2518.0"
    node.vm.network "public_network", ip: "192.168.1.13"
    node.vm.hostname = "node2"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--pae", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.memory = 2048
    end
    ssh_pub_key = File.readlines("macbook_key.pub").first.strip
    node.vm.provision 'shell', inline: "echo '#{ssh_pub_key}' >> /home/vagrant/.ssh/authorized_keys", privileged: false
  end

  config.vm.define "node3" do |node|
    node.vm.box = "cloud-image/debian-13"
    node.vm.box_version = "20260623.2518.0"
    node.vm.network "public_network", ip: "192.168.1.14"
    node.vm.hostname = "node3"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--pae", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.memory = 2048
    end
    ssh_pub_key = File.readlines("macbook_key.pub").first.strip
    node.vm.provision 'shell', inline: "echo '#{ssh_pub_key}' >> /home/vagrant/.ssh/authorized_keys", privileged: false
  end
end
