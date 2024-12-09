terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
    }
  }
}

resource "proxmox_lxc" "docker_01" {

  vmid         = var.vmid
  hostname     = "docker-01"
  target_node  = "YOUR_PROXMOX_NODE_NAME"
  ostemplate   = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  password     = "root_password"
  unprivileged = false
  cores        = 4
  memory       = 4096
  swap         = 1024
  start        = true
  onboot       = true

  rootfs {
    storage = "local-lvm"
    size    = "50G"
  }

  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "IP_WANTED_FOR_THIS_LXC/24"
    gw      = "YOUR_ROUTER_IP_ADDRESS"
  }

  provisioner "remote-exec" {
    inline = [
      # Configure features after creation
      "echo 'features: nesting=1,mount=nfs;cifs' >> /etc/pve/lxc/${var.vmid}.conf",
      "echo 'lxc.cap.drop:' >> /etc/pve/lxc/${var.vmid}.conf",
      "echo 'lxc.cgroup2.devices.allow: c 226:0 rwm' >> /etc/pve/lxc/${var.vmid}.conf",
      "echo 'lxc.cgroup2.devices.allow: c 226:128 rwm' >> /etc/pve/lxc/${var.vmid}.conf",
      "echo 'lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file' >> /etc/pve/lxc/${var.vmid}.conf",
      "echo 'lxc.hook.pre-start: sh -c \"chown 0:108 /dev/dri/renderD128\"' >> /etc/pve/lxc/${var.vmid}.conf",
      "pct start ${var.vmid}", #

      # Configure locales
      "pct exec ${var.vmid} -- apt-get update && apt-get install -y locales sudo",
      "pct exec ${var.vmid} -- locale-gen en_US.UTF-8",
      "pct exec ${var.vmid} -- update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8",

      # Enable root login
      "pct exec ${var.vmid} -- sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "pct exec ${var.vmid} -- echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config",
      "pct exec ${var.vmid} -- systemctl restart sshd"
    ]

    connection {
      type        = "ssh"
      user        = var.proxmox_user
      password    = var.proxmox_password
      host        = var.proxmox_host
    }
  }

  # Copy SSH key to the container
  provisioner "file" {
    source      = "~/.ssh/id_ed25519.pub"
    destination = "/root/.ssh/authorized_keys"

    connection {
      type        = "ssh"
      user        = "root"
      password    = "root_password"
      host        = "IP_WANTED_FOR_THIS_LXC"
    }
  }
}

resource "local_file" "ansible_inventory" {
  depends_on = [proxmox_lxc.docker_01]

  content = <<EOT
[docker]
docker-01 ansible_host=${split("/", proxmox_lxc.docker_01.network.0.ip)[0]} ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_ed25519
EOT

  filename = "../ansible/inventory/inventory.ini"
}

resource "null_resource" "run_ansible_docker" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/nfs_mount/main.yml"
  }
}

resource "null_resource" "run_ansible_docker_install" {
  depends_on = [null_resource.run_ansible_docker]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/docker/main.yml"
  }
}

resource "null_resource" "run_ansible_homepage" {
  depends_on = [null_resource.run_ansible_docker_install]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/docker/install-homepage.yml"
  }
}

resource "null_resource" "run_ansible_traefik" {
  depends_on = [null_resource.run_ansible_docker_install]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory/inventory.ini ../ansible/roles/docker/install-traefik.yml"
  }
}
