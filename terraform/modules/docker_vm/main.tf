terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.7.0"
    }
  }
}


resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = "ubuntu-vm"                
  target_node = "YOUR_PROXMOX_NODE_NAME"                   
  clone       = "ubuntu-server-jammy"      
#  vmid        = 501                      
  cores       = 2                         
  memory      = 8192                      
  sockets     = 1                         
  agent       = 1                         

  # Cloud-Init Drive (slot ide0)
  disk {
    slot    = "ide0"
    type    = "cloudinit"
    storage = "local-lvm"
  }

  # HDD (slot virtio0)
  disk {
    slot    = "virtio0"
    size    = "25G"
    type    = "disk"
    storage = "local-lvm"
    cache   = "none"
  }

 
  network {
    id     = 0                            
    model  = "virtio"                    
    bridge = "vmbr0"                   
  }

  os_type = "cloud-init"
  # static IP
  ipconfig0 = "ip=IP_MACHINE/24,gw=GateWay_IP"

  # Cloud-Init
  ciuser     = "root"                     
  cipassword = "yoursecretpassword"    
  sshkeys = <<EOF
  YOUR_SSH_KEY
  EOF

}



resource "time_sleep" "wait_1_minute" {
  depends_on = [proxmox_vm_qemu.ubuntu_vm]
  create_duration = "60s"
}



# Create Ansible inventory
resource "local_file" "ansible_inventory" {
  depends_on = [time_sleep.wait_1_minute]

  content = <<EOT
[docker]
docker-01 ansible_host=IP_DEPLOYMENT ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
EOT

  filename = "../ansible/inventory/inventory.ini"
}

# NFS mount
resource "null_resource" "run_ansible_docker" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = "LC_ALL=C.UTF-8 LANG=C.UTF-8 ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/nfs_mount/main.yml"
  }
}

resource "null_resource" "run_ansible_docker_install" {
  depends_on = [null_resource.run_ansible_docker]

  provisioner "local-exec" {
    command = "LC_ALL=C.UTF-8 LANG=C.UTF-8 ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/docker/main.yml"
  }
}

# getHomepage docker install
resource "null_resource" "run_ansible_homepage" {
  depends_on = [null_resource.run_ansible_docker_install]

  provisioner "local-exec" {
    command = "LC_ALL=C.UTF-8 LANG=C.UTF-8 ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/docker/install-homepage.yml"
  }
}

# Traefik
resource "null_resource" "run_ansible_traefik" {
  depends_on = [null_resource.run_ansible_homepage]

  provisioner "local-exec" {
    command = "LC_ALL=C.UTF-8 LANG=C.UTF-8 ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/docker/install-traefik.yml"
  }
}
