# Initial setup

1. Run `terraform apply` (the droplet's IP will be written to `ansible/inventory.yml` automatically).


2. SSH into your DigitalOcean droplet:

<!-- Wait for 1min for the droplet initialisation -->
```
ssh -i /Users/alexander/.ssh/DigitalOcean/mtproxy ubuntu@$(terraform output -raw droplet_ip)
```


# MTProxy
a. provision with Ansible:

```
ansible-playbook -i ansible/inventory.yml ansible/provision-mtproxy.yml
```

b. Generate MTProxy connection string.
```
echo "tg://proxy?server=$(terraform output -raw droplet_ip)&port=443&secret=$(grep -E '^SECRET=' .env | cut -d'=' -f2)"
```



# Wireguard

a. Deploy the gateway first:
```bash
ansible-playbook -i ansible/inventory.yml ansible/provision-wireguard-gateway.yml \
  --extra-vars "@ansible/wireguard-gateway-vars.yml"
```

b. Get the gateway's IP and deploy client (run it under root):
```bash
ansible-playbook -i ansible/inventory.yml ansible/provision-wireguard-client.yml \
  --extra-vars "@ansible/wireguard-client-vars.yml" \
  --ask-become-pass
```


To turn WireGuard off:
```bash
sudo systemctl stop wg-quick@wg0
sudo digitalocean/remove-wireguard-killswitch.sh # That internet remains available
```


To turn WireGuard back on:
```bash
sudo systemctl daemon-reload
sudo systemctl restart wg-quick@wg0
```



## -- Destroying the Droplet and Cleaning SSH Known Hosts -- ##

To destroy your droplet and remove its SSH key from known_hosts (to avoid SSH warnings when recreating):

```
terraform destroy
ssh-keygen -R $(terraform output -raw droplet_ip)
```