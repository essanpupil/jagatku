resource "libvirt_pool" "default" {
  name = var.storage_pool
  
  # Pool type: 'dir' for directory-based pool, 'logical', 'network', etc.
  target {
    path = "/var/lib/libvirt/images"
    type = "dir"
  }
  
  # Ensure pool is active
  state = "active"
}

resource "libvirt_network" "nat" {
  name = var.network_name
  
  # Network configuration for NAT
  network {
    network = "192.168.122.0/24"  # Default libvirt NAT network
    forward {
      mode = "nat"
    }
  }
  
  # Forwarding rules for NAT
  forward {
    mode = "nat"
    
    nat {
      network = "192.168.122.0/24"
      start = "192.168.122.100"
      end = "192.168.122.250"
    }
  }
  
  # Network options (DHCP, DNS, etc.)
  forward {
    mode = "nat"
    
    nat {
      network = "192.168.122.0/24"
      start = "192.168.122.100"
      end = "192.168.122.250"
    }
    
    dhcp {
      start = "192.168.122.100"
      end = "192.168.122.250"
      lease_time = 3600
    }
  }
  
  # Network options for libvirt
  forward {
    mode = "nat"
    
    nat {
      network = "192.168.122.0/24"
      start = "192.168.122.100"
      end = "192.168.122.250"
    }
  }
  
  # Define the network (create if not exists)
  state = "active"
}

resource "libvirt_volume" "disk" {
  name = "${var.vm_name}.qcow2"
  pool_id = libvirt_pool.default.id
  
  # Volume capacity in GiB (convert to bytes for Terraform)
  size = var.disk_size_gb * 1024 * 1024 * 1024
  
  # Volume allocation (pre-allocate space)
  allocation = var.disk_size_gb * 1024 * 1024 * 1024
  
  # Volume format
  format = "qcow2"
  
  # Volume target path (for file-based volumes)
  target = "/var/lib/libvirt/images/${var.vm_name}.qcow2"
  
  # Volume state (create if not exists)
  state = "active"
}

resource "libvirt_domain" "controller" {
  name = var.vm_name
  
  # Memory configuration (convert MB to KiB)
  memory {
    current = var.vm_memory_mb * 1024
    max     = var.vm_memory_mb * 1024
  }
  
  # CPU configuration
  cpu {
    sockets = 1
    cores   = var.vm_vcpus
    threads = 1
    
    mode {
      type = "host-passthrough"
      
      feature {
        policy = "disable"
      }
    }
  }
  
  # OS configuration
  os {
    type = "hvm"
    
    boot_order = ["hd"]
  }
  
  # Disk device configuration
  disk {
    driver = {
      name   = "qemu"
      type   = "qcow2"
    }
    
    source {
      file_id = libvirt_volume.disk.id
    }
    
    target {
      dev  = "vda"
      bus  = "virtio"
    }
    
    cache_mode = "none"
  }
  
  # Network interface configuration
  network_interface {
    model = "virtio"
    
    bridge = var.network_name
    
    # For NAT network, use network_id instead of bridge
    network {
      name = var.network_name
    }
  }
  
  # Console configuration (serial)
  console {
    type = "pty"
    
    target {
      port = 0
      type = "serial"
    }
  }
  
  # Domain state (create and start)
  state = "running"
}
