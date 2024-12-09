terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
    }
  }
}

resource "null_resource" "download_template" {
  provisioner "remote-exec" {
    inline = [
      "wget -q -O /var/lib/vz/template/cache/debian-12-standard_12.7-1_amd64.tar.zst http://ftp.cn.debian.org/proxmox/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
    ]
    connection {
      type     = "ssh"
      host     = var.proxmox_host
      user     = var.proxmox_user
      password = var.proxmox_password
    }
  }
}
