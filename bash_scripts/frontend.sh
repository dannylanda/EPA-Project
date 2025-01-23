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

# Update package lists
echo "Running apt update..." | tee -a $LOG_FILE
sudo apt -y update
check_exit_status "apt update"

# Upgrade installed packages
echo "Running apt upgrade..." | tee -a $LOG_FILE
sudo apt -y upgrade
check_exit_status "apt upgrade"

# Ensure /var/www/html exists and is empty
echo "Preparing /var/www/html directory..." | tee -a $LOG_FILE
sudo rm -rf /var/www/html
sudo mkdir -p /var/www/html
check_exit_status "prepare /var/www/html"

# Download and extract WordPress
echo "Downloading WordPress..." | tee -a $LOG_FILE
sudo apt -y install unzip
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip
check_exit_status "download WordPress"

echo "Extracting WordPress..." | tee -a $LOG_FILE
sudo unzip /var/www/latest.zip -d /var/www/
check_exit_status "extract WordPress"
sudo rm /var/www/latest.zip

# Move WordPress files to /var/www/html
if [ -d "/var/www/wordpress" ]; then
    echo "Moving WordPress files to /var/www/html..." | tee -a $LOG_FILE
    sudo mv /var/www/wordpress/* /var/www/html/
    sudo rm -rf /var/www/wordpress
else
    echo "Error: WordPress extraction failed." | tee -a $LOG_FILE
    exit 1
fi

# Configure WordPress
echo "Configuring WordPress..." | tee -a $LOG_FILE
if [ -f "/var/www/html/wp-config-sample.php" ]; then
    sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sudo chmod 640 /var/www/html/wp-config.php
    check_exit_status "configure wp-config.php"
else
    echo "Error: wp-config-sample.php not found." | tee -a $LOG_FILE
    exit 1
fi

# Set proper ownership and permissions
echo "Setting ownership and permissions..." | tee -a $LOG_FILE
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
check_exit_status "set ownership and permissions"

# Add WordPress salts
echo "Adding WordPress salts..." | tee -a $LOG_FILE
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
sudo sed -i "s|$STRING|$SALT|" /var/www/html/wp-config.php
check_exit_status "add WordPress salts"

# Install and start Nginx
echo "Installing and starting Nginx..." | tee -a $LOG_FILE
sudo apt -y install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
check_exit_status "start Nginx"

# Install PHP and necessary extensions
echo "Installing PHP and extensions..." | tee -a $LOG_FILE
sudo apt -y install php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
sudo php -v | tee -a $LOG_FILE
check_exit_status "install PHP"

# Final Nginx reload
echo "Reloading Nginx..." | tee -a $LOG_FILE
sudo nginx -t && sudo systemctl reload nginx
check_exit_status "reload Nginx"

echo "Script completed successfully!" | tee -a $LOG_FILE
