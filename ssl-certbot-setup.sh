#!/bin/bash

# Update package list and install Certbot and Certbot Nginx plugin
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y certbot python3-certbot-nginx

# Define your email
EMAIL="danny.landa@jdplc.com"

# Define your domain(s)
DOMAIN="brandscribe.tech"

# Use Certbot to obtain and install the SSL certificate for the specified domain
sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN 
sudo systemctl stop apache2
sudo apt purge apache2 -y
sudo apt-get purge apache2* -y
systemctl reload nginx.service 
#if this doesn't work change SSL to full on Cloudflare afterwards

# Nginx unit test that will reload Nginx to apply changes ONLY if the test is successful
sudo nginx -t && sudo systemctl reload nginx

# Run the WordPress installation script
sudo bash /root/EPA-Project/wordpress-installation-setup.sh