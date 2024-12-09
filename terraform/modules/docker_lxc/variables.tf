variable "proxmox_api_url" {
  type        = string
}

variable "proxmox_api_token_id" {
  type        = string
}

variable "proxmox_api_token_secret" {
  type        = string
}

variable "proxmox_host" {
  type        = string
}

variable "proxmox_user" {
  type        = string
}

variable "proxmox_password" {
  type        = string
}

variable "vmid" {
  type        = number
  default     = 110
}

variable "hostname" {
  type        = string
  default     = "docker-01"
}

variable "password" {
  type        = string
  default     = "root_password"
}

variable "cores" {
  type        = number
  default     = 4
}

variable "memory" {
  type        = number
  default     = 4096
}

variable "swap" {
  type        = number
  default     = 1024
}

variable "rootfs_storage" {
  type        = string
  default     = "local-lvm"
}

variable "rootfs_size" {
  type        = string
  default     = "50G"
}

variable "network_ip" {
  type        = string
  default     = "PUT_HERE_IP_WANTED_FOR_LXC/24"
}

variable "network_gateway" {
  type        = string
  default     = "PUT_HERE_YOUR_ROUTER_IP"
}

variable "ssh_key_path" {
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}