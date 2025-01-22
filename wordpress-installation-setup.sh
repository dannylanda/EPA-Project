#!/bin/bash

# Install AWS CLI
sudo snap install aws-cli --classic

# Install required packages
sudo apt -y install unzip
sudo apt -y install mysql-client  # Use mariadb-client if using MariaDB

# Download and extract WordPress
sudo rm -rf /var/www/html  # Ensure target directory is empty
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip
sudo mv /var/www/wordpress /var/www/html

# Generate a random username and password
username=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 25)
password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 25)

# Save credentials to creds.txt (username first, then password)
echo $username > creds.txt
echo $password >> creds.txt
sudo mv creds.txt /root/EPA-Project/

# Upload creds.txt to S3 bucket
sudo aws s3 cp /root/EPA-Project/creds.txt s3://brandscribe-backup/creds.txt

# Create MySQL database and user
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql -e "CREATE USER IF NOT EXISTS $username@localhost IDENTIFIED BY '$password'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* TO $username@localhost"
sudo mysql -e "FLUSH PRIVILEGES"

# Move the wp-config-sample.php to wp-config.php
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php
sudo chown -R www-data:www-data /var/www/html/

# Replace placeholders with actual credentials in wp-config.php
sed -i "s/password_here/$password/g" /var/www/html/wp-config.php
sed -i "s/username_here/$username/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/$username/g" /var/www/html/wp-config.php

# Create a dump of the WordPress database
sudo mysqldump -u $username -p$password $username > /tmp/wordpress_dump.sql

# Compress the SQL dump
sudo gzip /tmp/wordpress_dump.sql

# Upload the dump to S3 bucket
sudo aws s3 cp /tmp/wordpress_dump.sql.gz s3://brandscribe-backup/wordpress_dump.sql.gz

# Clean up the dump file locally
sudo rm /tmp/wordpress_dump.sql.gz

echo "WordPress database dump successfully created and uploaded to S3."
