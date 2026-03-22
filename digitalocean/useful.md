# Ansible & SSH Usage for Droplet Access

After running `terraform apply`, the droplet's IP will be written to `ansible/inventory.yml` automatically.


To SSH into your DigitalOcean droplet:

<!-- Wait for 10sec for the droplet initialisation -->
```
ssh -i /Users/alexander/.ssh/DigitalOcean/mtproxy ubuntu@$(terraform output -raw droplet_ip)
```

To provision with Ansible:

```
ansible-playbook -i ansible/inventory.yml ansible/provision-mtproxy.yml
```


<!-- Command to generate MTProxy connection string -->
```
echo "tg://proxy?server=$(terraform output -raw droplet_ip)&port=443&secret=$(grep -E '^SECRET=' .env | cut -d'=' -f2)"
```