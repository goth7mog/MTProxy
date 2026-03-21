# Ansible & SSH Usage for Droplet Access

After running `terraform apply`, the droplet's IP will be written to `ansible/inventory.yml` automatically.

To SSH into your DigitalOcean droplet:

```
ssh -i /Users/alexander/.ssh/DigitalOcean/mtproxy ubuntu@$(terraform output -raw droplet_ip)
```

To provision with Ansible:

```
ansible-playbook -i ansible/inventory.yml ansible/provision-mtproxy.yml
```

