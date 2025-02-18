#!/bin/bash

# Log file path
LOG_FILE="$HOME/script_execution.log"

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

# Install AWS CLI tool for interacting with AWS services
sudo snap install aws-cli --classic

# Re-run updates to ensure all packages are up to date
sudo apt -y update && sudo apt -y upgrade

# Create a test file to verify script execution
sudo touch /home/ubuntu/testing.txt

# Install and start Nginx web server
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx 

# Log the status of the Nginx service
sudo sh -c 'systemctl status nginx > /home/ubuntu/testing.txt'

# Install PHP and required extensions for WordPress
sudo apt -y install php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl

# Log the PHP version
sudo sh -c 'php -v >> /home/ubuntu/testing.txt'

# Log the contents of the custom Nginx configuration file before moving it
sudo sh -c 'cat /home/ubuntu/EPA-Project/configs/nginx.conf >> /home/ubuntu/testing.txt'

# Move custom Nginx configuration file into place
sudo mv /home/ubuntu/EPA-Project/configs/nginx.conf /etc/nginx/conf.d/epa-domain.conf

# Test Nginx configuration and reload if valid
sudo nginx -t && sudo systemctl reload nginx

# Update package lists and install Certbot for SSL certificates
sudo apt -y update && sudo apt -y upgrade
sudo apt -y install certbot python3-certbot-nginx

# Define email and domain for SSL certificate registration
EMAIL="REPLACE_EMAIL"
DOMAIN="REPLACE_DOMAIN"

# Use Certbot to obtain and install the SSL certificate for Nginx
sudo certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN

# Validate Nginx configuration and reload to apply SSL settings
sudo nginx -t && sudo systemctl reload nginx

# Install WordPress
sudo rm -rf /var/www/html
sudo apt -y install unzip 
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip 
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip 
sudo mv /var/www/wordpress /var/www/html

# Rename WordPress config file
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 

# Download and install application from AWS S3
sudo aws s3 cp s3://brandscribe-backup/ai-content-rewriter-v2.zip /var/www/html/wp-content/plugins/ai-content-rewriter-v2.zip 
sudo unzip -o /var/www/html/wp-content/plugins/ai-content-rewriter-v2.zip -d /var/www/html/wp-content/plugins/
sudo rm /var/www/html/wp-content/plugins/ai-content-rewriter-v2.zip

# Set correct ownership and permissions for WordPress files
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 0755 {} \;
sudo find /var/www/html/ -type f -exec chmod 0644 {} \;

# Update wp-config.php with database credentials
sudo sed -i "s/username_here/DB_USERNAME/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/DB_PASSWORD/g" /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/DB_USERNAME/g" /var/www/html/wp-config.php
sudo sed -i "s/localhost/BACKEND_IP/g" /var/www/html/wp-config.php

# Fetch and update WordPress authentication salts
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
sudo printf '%s\n' "g/$STRING/d" a "$SALT" . w | sudo ed -s /var/www/html/wp-config.php

# Backup the updated wp-config.php to AWS S3
aws s3 cp /var/www/html/wp-config.php s3://brandscribe-backup

# Install chkrootkit for vulnerability scanning
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install chkrootkit -y

# Run chkrootkit and save results to a file
sudo chkrootkit > /root/vulnerability_scan_output.txt