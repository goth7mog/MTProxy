# main.tf
# Terraform configuration for deploying a DigitalOcean Droplet

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

resource "digitalocean_droplet" "web" {
  name   = "mtp-droplet2"
  region = "ams3" # Amsterdam region
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-22-04-x64"

  ssh_keys = [
    var.ssh_fingerprint
  ]

  user_data = file("${path.module}/cloud-init.yaml")

  provisioner "local-exec" {
    command = "echo 'droplet ansible_host=${self.ipv4_address} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/DigitalOcean/mtproxy' > ${path.module}/ansible/inventory"
  }
}

output "droplet_ip" {
  value = digitalocean_droplet.web.ipv4_address
}
