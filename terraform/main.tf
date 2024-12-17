terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}


module "docker_vm" {
  source = "./modules/docker_vm"
  proxmox_host         = var.proxmox_host
  proxmox_user         = var.proxmox_user
  proxmox_password     = var.proxmox_password
  proxmox_api_url      = var.proxmox_api_url
  proxmox_api_token_id = var.proxmox_api_token_id
  proxmox_api_token_secret = var.proxmox_api_token_secret
}

## ONLY FOR FUTURE EXAMPLE
# module "docker_lxc" {
#   source = "./modules/docker_lxc"
#   proxmox_host         = var.proxmox_host
#   proxmox_user         = var.proxmox_user
#   proxmox_password     = var.proxmox_password
#   proxmox_api_url      = var.proxmox_api_url
#   proxmox_api_token_id = var.proxmox_api_token_id
#   proxmox_api_token_secret = var.proxmox_api_token_secret
  
#   depends_on = [
#      module.docker_template 
#      ]
# }


