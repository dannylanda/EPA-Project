#!/bin/bash

# Log file path
LOG_FILE="/var/log/script_execution.log"

# Function to check the exit status of the last executed command
check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed. Check the logs for details." | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 succeeded." | tee -a $LOG_FILE
    fi
}

# Clear the log file at the beginning of the script
echo "Starting script execution: $(date)" > $LOG_FILE
echo "----------------------------------------" | tee -a $LOG_FILE

# Update package lists
echo "Updating package lists..." | tee -a $LOG_FILE
sudo apt -y update
check_exit_status "apt update"

# Upgrade installed packages
echo "Upgrading installed packages..." | tee -a $LOG_FILE
sudo apt -y upgrade
check_exit_status "apt upgrade"

# Install necessary tools (wget, unzip)
echo "Installing essential tools (wget, unzip)..." | tee -a $LOG_FILE
sudo apt -y install wget unzip
check_exit_status "install essential tools"

# Prepare /var/www/html directory
echo "Preparing /var/www/html directory..." | tee -a $LOG_FILE
sudo rm -rf /var/www/html
sudo mkdir -p /var/www/html
check_exit_status "prepare /var/www/html"

# Download and extract WordPress
TEMP_DIR=$(mktemp -d)
echo "Downloading WordPress to temporary directory..." | tee -a $LOG_FILE
sudo wget -O $TEMP_DIR/latest.zip https://wordpress.org/latest.zip
check_exit_status "download WordPress"

echo "Extracting WordPress..." | tee -a $LOG_FILE
sudo unzip $TEMP_DIR/latest.zip -d $TEMP_DIR
check_exit_status "extract WordPress"
sudo rm -rf $TEMP_DIR/latest.zip  # Remove the zip file after extraction

echo "Moving WordPress files to /var/www/html..." | tee -a $LOG_FILE
sudo mv $TEMP_DIR/wordpress/* /var/www/html/
sudo rm -rf $TEMP_DIR  # Clean up temporary directory
check_exit_status "move WordPress files"

# Configure wp-config.php
echo "Configuring wp-config.php..." | tee -a $LOG_FILE
if [ -f "/var/www/html/wp-config-sample.php" ]; then
    sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sudo chmod 640 /var/www/html/wp-config.php
    check_exit_status "configure wp-config.php"
else
    echo "Error: wp-config-sample.php not found in /var/www/html." | tee -a $LOG_FILE
    exit 1
fi

# Add WordPress salts
echo "Adding WordPress salts..." | tee -a $LOG_FILE
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
check_exit_status "fetch WordPress salts"

sudo sed -i "/AUTH_KEY/d" /var/www/html/wp-config.php
sudo sed -i "/put your unique phrase here/d" /var/www/html/wp-config.php
printf '%s\n' "$SALT" | sudo tee -a /var/www/html/wp-config.php > /dev/null
check_exit_status "add WordPress salts"

# Set proper ownership and permissions for /var/www/html
echo "Setting ownership and permissions for /var/www/html..." | tee -a $LOG_FILE
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;
check_exit_status "set ownership and permissions"

# Install and start Nginx
echo "Installing and starting Nginx..." | tee -a $LOG_FILE
sudo apt -y install nginx
check_exit_status "install Nginx"

sudo systemctl start nginx
sudo systemctl enable nginx
check_exit_status "start Nginx"

# Install PHP and necessary extensions
echo "Installing PHP and extensions..." | tee -a $LOG_FILE
sudo apt -y install php-fpm php php-cli php-common php-imap php-snmp php-xml php-zip php-mbstring php-curl php-mysqli php-gd php-intl
check_exit_status "install PHP"

# Restart and test Nginx configuration
echo "Testing and reloading Nginx..." | tee -a $LOG_FILE
sudo nginx -t
check_exit_status "test Nginx configuration"

sudo systemctl reload nginx
check_exit_status "reload Nginx"

echo "Script completed successfully!" | tee -a $LOG_FILE
echo "----------------------------------------" | tee -a $LOG_FILE
