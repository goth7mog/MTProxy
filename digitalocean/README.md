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

The playbooks are thin entry points for reusable roles:

```text
ansible/roles/mtproxy/
ansible/roles/wireguard/
```

Use `provision-wireguard-gateway.yml` to provision the full-tunnel WireGuard gateway.

To provision a client VM, add a `client` host to the Ansible inventory and put
the gateway public key, endpoint, and client private key in a local variables
file that is excluded from Git:

```yaml
wireguard_gateway_public_key: "GATEWAY_PUBLIC_KEY"
wireguard_gateway_endpoint: "GATEWAY_PUBLIC_IP"
```

Then run:

```bash
ansible-playbook -i ansible/inventory.yml ansible/provision-wireguard-client.yml \
  --extra-vars "@ansible/wireguard-client-vars.yml" \
  --ask-become-pass
```

For a local client, the playbook needs root privileges to install WireGuard and
write under `/etc/wireguard`. Enter the local VM user's sudo password when
prompted, or run `sudo -v` first and omit `--ask-become-pass` if sudo credentials
are already cached. Do not store the password in the inventory or variables
files.

Generate the gateway and client key pairs locally, then store the private keys
in local Git-ignored variables files. Ansible transfers them over encrypted SSH
and the roles copy each private key only to its respective VM. The client role
routes IPv4 and IPv6 default traffic and DNS through WireGuard and installs a
kill switch.

4. Generate MTProxy connection string.
```
echo "tg://proxy?server=$(terraform output -raw droplet_ip)&port=443&secret=$(grep -E '^SECRET=' .env | cut -d'=' -f2)"
```

## Provisioning a WireGuard full-tunnel gateway

The WireGuard playbook provisions the Droplet as a gateway. It enables IPv4/IPv6
forwarding, NAT, and the WireGuard UDP port. Client traffic is encrypted from
the client to this gateway; each client must use `AllowedIPs = 0.0.0.0/0, ::/0`
to request a full tunnel. The client must also route DNS through the tunnel and
install a kill switch to prevent fallback traffic outside WireGuard.

Define `wireguard_peers` in a local Git-ignored variables file, then run:

```bash
ansible-playbook -i ansible/inventory.yml ansible/provision-wireguard-gateway.yml \
  --extra-vars "@ansible/wireguard-gateway-vars.yml"
```

Each peer needs a unique tunnel address, for example:

```yaml
wireguard_peers:
  - name: client-vm
    public_key: "CLIENT_PUBLIC_KEY"
    allowed_ips:
      - 10.66.66.2/32
      - fd42:42:42::2/128
```

Do not commit private keys or local WireGuard variables files to the repository.

Generate the keys locally with:

```bash
umask 077
wg genkey > gateway_private.key
wg pubkey < gateway_private.key > gateway_public.key
wg genkey > client_private.key
wg pubkey < client_private.key > client_public.key
```

Put the private key values and public key values in local variables files:

```yaml
# wireguard-gateway-vars.yml
wireguard_server_private_key: "GATEWAY_PRIVATE_KEY"
wireguard_peers:
  - name: client-vm
    public_key: "CLIENT_PUBLIC_KEY"
    allowed_ips:
      - 10.66.66.2/32
      - fd42:42:42::2/128
```

```yaml
# wireguard-client-vars.yml
wireguard_client_private_key: "CLIENT_PRIVATE_KEY"
wireguard_gateway_public_key: "GATEWAY_PUBLIC_KEY"
wireguard_gateway_endpoint: "GATEWAY_PUBLIC_IP"
```

Run the gateway and client playbooks with their corresponding local variables
files:

```bash
ansible-playbook -i ansible/inventory.yml ansible/provision-wireguard-gateway.yml \
  --extra-vars "@ansible/wireguard-gateway-vars.yml"

ansible-playbook -i ansible/inventory.yml ansible/provision-wireguard-client.yml \
  --extra-vars "@ansible/wireguard-client-vars.yml" \
  --ask-become-pass
```



## Destroying the Droplet and Cleaning SSH Known Hosts

To destroy your droplet and remove its SSH key from known_hosts (to avoid SSH warnings when recreating):

```
terraform destroy
ssh-keygen -R $(terraform output -raw droplet_ip)
```