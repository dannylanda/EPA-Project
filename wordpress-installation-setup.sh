#!/bin/bash 

# Entering the html directory 
cd /var/www/html

# Install AWS CLI tools
snap install aws-cli --classic

# Installing required packages
sudo apt -y install unzip

# Install/Unzip/Remove WordPress
sudo wget https://wordpress.org/latest.zip 
sudo unzip -o latest.zip  # Overwrite any existing files without prompting
sudo rm -f latest.zip     # Force removal without confirmation

# Download the credentials file from S3
aws s3 cp "s3://brandscribe-backup/creds for database dump.txt" /tmp/creds.txt

# Extract username and password from the credentials file
username=$(grep -i "username" /tmp/creds.txt | awk '{print $2}')
password=$(grep -i "password" /tmp/creds.txt | awk '{print $2}')

# Create the MariaDB Database and User using extracted credentials
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql -e "CREATE USER $username@localhost IDENTIFIED BY '$password'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* TO $username@localhost"
sudo mysql -e "FLUSH PRIVILEGES"

# Connect to S3 Bucket and restore the WordPress database dump
aws s3 cp s3://brandscribe-backup/wordpress_dump.sql.gz /tmp/wordpress_dump.sql.gz
sudo gunzip -f /tmp/wordpress_dump.sql.gz  # Force overwrite if the file already exists
sudo mysql $username < /tmp/wordpress_dump.sql
sudo rm -f /tmp/wordpress_dump.sql  # Force removal without confirmation

# Set up the WordPress config file
sudo mv -f /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php  # Force overwrite
sudo chmod 640 /var/www/html/wordpress/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/wordpress

# Update wp-config.php with the database credentials
sed -i "s/database_name_here/$username/g" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$username/g" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$password/g" /var/www/html/wordpress/wp-config.php
