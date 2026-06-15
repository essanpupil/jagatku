output "vm_name" {
  value = libvirt_domain.controller.name
}

output "vm_ip_address" {
  value = libvirt_domain.controller.ip_addresses[0]
}

output "vm_memory" {
  value = "${libvirt_domain.controller.memory.current / 1024} MB"
}

output "vm_vcpus" {
  value = libvirt_domain.controller.cpus.vcpus
}

output "vm_state" {
  value = libvirt_domain.controller.state
}