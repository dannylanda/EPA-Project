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

# Clone the GitHub repository
echo "Cloning GitHub repository..." | tee -a $LOG_FILE
sudo git clone -b Scripts-1.1 https://github.com/dannylanda/EPA-Project.git /root/EPA-Project
check_exit_status "git clone"

# Change permissions of the cloned repository
echo "Changing permissions of the cloned repository..." | tee -a $LOG_FILE
sudo chmod -R 755 /root/EPA-Project/bash_scripts #change this to just be specific files that need execute permissions
check_exit_status "chmod"

# Run the setup script
log "Running lemp-setup.sh script..."

sudo touch /root/EPA-Project/testing.txt
sudo apt -y install nginx
sudo systemctl start nginx && sudo systemctl enable nginx 
sudo systemctl status nginx > /root/EPA-Project/testing.txt
sudo apt -y install php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v >> /root/EPA-Project/testing.txt
sudo systemctl status php8.3-fpm >> /root/EPA-Project/testing.txt

sudo mv /root/EPA-Project/configs/nginx.conf /etc/nginx/conf.d/nginx.conf

# Update nginx configuration file
sed -i "s/DOMAIN/brandscribe.tech/g" /etc/nginx/conf.d/nginx.conf 
nginx -t && systemctl reload nginx # && means it wont complete the next command if the first one fails

# install Certbot and Certbot Nginx plugin
sudo apt -y install certbot
sudo apt -y install python3-certbot-nginx

# # Define your email
CERTBOTMAIL=EMAIL
CERTBOTURL=DOMAIN

sudo certbot --nginx --non-interactive --agree-tos --email CERTBOTMAIL -d CERTBOTURL

# Nginx unit test that will reload Nginx to apply changes ONLY if the test is successful
sudo nginx -t && systemctl reload nginx

# Install WordPress
sudo rm -rf /var/www/html
sudo apt -y install unzip 
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip 
sudo unzip -o /var/www/latest.zip -d /var/www/html
sudo rm /var/www/latest.zip 
mv /var/www/wordpress /var/www/html

sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/html/wp-config.php