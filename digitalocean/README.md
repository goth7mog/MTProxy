# Setup

1. Run `terraform apply` (the droplet's IP will be written to `ansible/inventory.yml` automatically).


2. SSH into your DigitalOcean droplet:

<!-- Wait for 1min for the droplet initialisation -->
```
ssh -i /Users/alexander/.ssh/DigitalOcean/mtproxy ubuntu@$(terraform output -raw droplet_ip)
```

3. provision with Ansible:

```
ansible-playbook -i ansible/inventory.yml ansible/provision-mtproxy.yml
```

4. Generate MTProxy connection string.
```
echo "tg://proxy?server=$(terraform output -raw droplet_ip)&port=443&secret=$(grep -E '^SECRET=' .env | cut -d'=' -f2)"
```



## Destroying the Droplet and Cleaning SSH Known Hosts

To destroy your droplet and remove its SSH key from known_hosts (to avoid SSH warnings when recreating):

```
terraform destroy
ssh-keygen -R $(terraform output -raw droplet_ip)
```