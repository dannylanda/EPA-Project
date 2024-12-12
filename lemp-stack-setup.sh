#!/bin/bash

# Create a file to store the output of LEMP stack unit tests
sudo touch /root/testing.txt

# Install and set up Nginx
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx # Starts Nginx and enables it to run on boot
sudo systemctl status nginx > /root/testing.txt # Logs the status of Nginx

# Install and set up MariaDB
sudo apt -y install mariadb-server
sudo systemctl start mariadb && sudo systemctl enable mariadb # Starts MariaDB and enables it on boot
systemctl status mariadb >> /root/testing.txt # Appends MariaDB status to the log file

# Install PHP and its required extensions
sudo apt -y install php php-cli php-common php-imap php-fpm php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v >> /root/testing.txt # Logs the installed PHP version

# Stop and disable Apache as Nginx is in use
sudo systemctl stop apache2
sudo systemctl disable apache2 
sudo apt purge apache2 apache2-utils apache2-bin apache2.2-common
# To completely remove Apache, uncomment the following command:
# sudo apt remove --purge apache2

# Rename the default Apache test page
sudo mv /var/www/html/index.html /var/www/html/index.html.old

# Move the custom Nginx configuration file into place
sudo mv /root/ai-content-application/nginx.conf /etc/nginx/conf.d/nginx.conf

# Replace the placeholder domain in the Nginx configuration with the actual domain
my_domain="brandscribe.tech"
sed -i "s/SERVERNAME/$my_domain/g" /etc/nginx/conf.d/nginx.conf

# Test Nginx configuration and reload it if the test passes
nginx -t && systemctl reload nginx

# Run the Certbot SSL installation script
sudo bash /root/ai-content-application/ssl-certbot-setup.sh
