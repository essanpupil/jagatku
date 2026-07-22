# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Define VM configurations
  nodes = [
    { name: "node1", ip: "192.168.1.12", memory: 4096 },
    { name: "node2", ip: "192.168.1.13", memory: 4096 },
    { name: "node3", ip: "192.168.1.14", memory: 4096 },
    { name: "node4", ip: "192.168.1.15", memory: 2048 }
  ]

  # Common VM settings
  box_name = "cloud-image/debian-13"
  box_version = "20260623.2518.0"
  disk_size = "30GB"
  cpus = 2

  ssh_pub_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILYanvolrdgHioh0pzS4yTeKOrGAxl6EAduAI4amzy1V essan@DreamSpace.local",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO252zj/2CT/WXUHmRKr8BnVF4iJiYkYHGvXlxaOe+pQ essan@houseone"
  ]

  nodes.each do |node_conf|
    config.vm.define node_conf[:name] do |node|
      node.vm.box = box_name
      node.vm.box_version = box_version
      node.vm.network "public_network", ip: node_conf[:ip]
      node.vm.hostname = node_conf[:name]
      node.vm.disk :disk, size: disk_size, primary: true

      node.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
        v.customize ["modifyvm", :id, "--ioapic", "on"]
        v.customize ["modifyvm", :id, "--pae", "on"]
        v.customize ["modifyvm", :id, "--cpus", cpus.to_s]
        v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
        v.memory = node_conf[:memory]
      end

      # Construct provisioning commands for each SSH public key
      ssh_keys_commands = ssh_pub_keys.map do |key|
        <<-SHELL
          if ! grep -qF '#{key}' /home/vagrant/.ssh/authorized_keys; then
            echo '#{key}' >> /home/vagrant/.ssh/authorized_keys
          fi
        SHELL
      end.join("\n")

      node.vm.provision "shell", inline: <<-SHELL
        #{ssh_keys_commands}
        chmod 600 /home/vagrant/.ssh/authorized_keys
        chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
      SHELL
    end
  end
end
