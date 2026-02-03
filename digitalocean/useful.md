# SSH Command for Droplet Access

Use the following command to SSH into your DigitalOcean droplet:

```
echo "DROPLET_IP=$(terraform output -raw droplet_ip)" >> .env
ssh -i /Users/alexander/.ssh/DigitalOcean/mtproxy ubuntu@$(terraform output -raw droplet_ip)
scp -i /Users/alexander/.ssh/DigitalOcean/mtproxy ./docker-compose.yml ubuntu@$(terraform output -raw droplet_ip):/home/ubuntu/docker-compose.yml
scp -i /Users/alexander/.ssh/DigitalOcean/mtproxy ./.env ubuntu@$(terraform output -raw droplet_ip):/home/ubuntu/.env
```

