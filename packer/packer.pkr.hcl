packer {
  required_plugins {
    proxmox-iso = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}