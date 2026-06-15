terraform {
    required_providers {
        libvirt = {
            source = "libvirt/libvirt"  # or use: terraform-provider-libvirt
        }
    }

    backend "local" {
        path = "terraform.tfstate"
    }
}

provider "libvirt" {
    uri = "qemu+ssh://${var.libvirt_user}@${var.libvirt_host}/system"
    key_file = "~/.ssh/id_rsa"  # or use password authentication

    # For local host (default)
    # uri = "qemu:///system"
}
