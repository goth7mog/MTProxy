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
  # You must set the DIGITALOCEAN_TOKEN environment variable or provide the token here
  token = var.digitalocean_token != "" ? var.digitalocean_token : (try(env.DIGITALOCEAN_TOKEN, ""))
}

resource "digitalocean_droplet" "web" {
  name   = "mtp-droplet2"
  region = "ams3" # Amsterdam region
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-22-04-x64"

  ssh_keys = [
    var.ssh_fingerprint
  ]

  user_data = <<-EOF
    #cloud-config
    users:
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        sudo: ["ALL=(ALL) NOPASSWD:ALL"]
        ssh-authorized-keys:
          - ${var.ssh_public_key}
    package_update: true
    package_upgrade: true
    runcmd:
      - apt-get install -y apt-transport-https ca-certificates curl software-properties-common
      - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
      - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      - apt-get update
      - apt-get install -y docker-ce
      - usermod -aG docker ubuntu
      - curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      - chmod +x /usr/local/bin/docker-compose
  EOF
}

output "droplet_ip" {
  value = digitalocean_droplet.web.ipv4_address
}
