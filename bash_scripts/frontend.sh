#!/bin/bash

# Log file path
LOG_FILE="/var/log/script_execution.log"

# Function to check the exit status of the last executed command
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed." | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 succeeded." | tee -a $LOG_FILE
    fi
}

# Clear the log file at the beginning of the script
> $LOG_FILE

# Update and Upgrade package lists
echo "Running apt update..." | tee -a $LOG_FILE
sudo apt -y update && sudo apt -y upgrade
check_exit_status "apt update and upgrade"

# Install the AWS CLI tool using Snap for managing AWS resources
snap install aws-cli --classic

sudo apt -y update && sudo apt -y upgrade
sudo touch /home/ubuntu/testing.txt
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx 
sudo systemctl status nginx > /home/ubuntu/testing.txt
sudo apt -y install php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v >> /home/ubuntu/testing.txt

cat /home/ubuntu/EPA-Project/configs/nginx.conf >> testing.txt

sudo mv /home/ubuntu/EPA-Project/configs/nginx.conf /etc/nginx/conf.d/epa-domain.conf

# Update nginx configuration file
nginx -t && systemctl reload nginx 

# Update package list and install Certbot and Certbot Nginx plugin
sudo apt -y update && sudo apt -y upgrade
sudo apt -y install certbot
sudo apt -y install python3-certbot-nginx

# Define your email and domain
EMAIL="REPLACE_EMAIL"
DOMAIN="REPLACE_DOMAIN"

# Use Certbot to obtain and install the SSL certificate
sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN

# Nginx unit test that will reload Nginx to apply changes ONLY if the test is successful
sudo nginx -t && systemctl reload nginx

# Install WordPress
sudo rm -rf /var/www/html
sudo apt -y install unzip 
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip 
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip 
mv /var/www/wordpress /var/www/html

sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 0755 {} \;
sudo find /var/www/html/ -type f -exec chmod 0644 {} \;

# Update wp-config.php with the database credentials
sed -i "s/username_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/password_here/DB_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/localhost/BACKEND_IP/g" /var/www/html/wp-config.php

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php

# This securely stores the wp-config.php credentials file in AWS S3 for later use or backup
aws s3 cp /var/www/html/wp-config.php s3://brandscribe-backup

# Install and run chkrootkit scan
sudo apt update
sudo apt install chkrootkit -y

# Run chrootkit
sudo chkrootkit -q > chkrootkit_output.txt 2>&1