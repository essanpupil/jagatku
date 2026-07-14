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
      v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      v.memory = 4096
    end
    node.vm.provision "shell", inline: <<-SHELL
      pub_key="#{File.read(File.expand_path('~/.ssh/id_ed25519.pub')).strip}"
      echo "$pub_key" >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
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
      v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      v.memory = 4096
    end
    node.vm.provision "shell", inline: <<-SHELL
      pub_key="#{File.read(File.expand_path('~/.ssh/id_ed25519.pub')).strip}"
      echo "$pub_key" >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
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
      v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      v.memory = 2048
    end
    node.vm.provision "shell", inline: <<-SHELL
      pub_key="#{File.read(File.expand_path('~/.ssh/id_ed25519.pub')).strip}"
      echo "$pub_key" >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
  end

  config.vm.define "node4" do |node|
    node.vm.box = "cloud-image/debian-13"
    node.vm.box_version = "20260623.2518.0"
    node.vm.network "public_network", ip: "192.168.1.15"
    node.vm.hostname = "node4"
    node.vm.disk :disk, size: "30GB", primary: true
    node.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
      v.customize ["modifyvm", :id, "--pae", "on"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      v.memory = 2048
    end
    node.vm.provision "shell", inline: <<-SHELL
      pub_key="#{File.read(File.expand_path('~/.ssh/id_ed25519.pub')).strip}"
      echo "$pub_key" >> /home/vagrant/.ssh/authorized_keys
      chmod 600 /home/vagrant/.ssh/authorized_keys
      chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    SHELL
  end
end
