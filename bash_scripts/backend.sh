#!/bin/bash

# Update the package lists and upgrade any installed packages to their latest versions
sudo apt -y update && sudo apt -y upgrade

# Install the AWS CLI tool using Snap for managing AWS resources
sudo snap install aws-cli --classic

# Install MariaDB server and client for database management
sudo apt -y install mariadb-server mariadb-client

# Modify the MariaDB configuration file to allow remote connections
# The bind-address is set to 0.0.0.0, meaning it will accept connections from any IP
sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Check if the MariaDB service is running properly
sudo mysqladmin ping

# Restart the MariaDB service to apply configuration changes
sudo systemctl restart mariadb

# Define database username and password variables (these should be replaced dynamically)
username=DB_USERNAME
password=DB_PASSWORD

# Store database credentials in a file for reference
# This is not a secure way to store credentials, consider using environment variables or a secrets manager
echo $username > /home/ubuntu/EPA-Project/creds.txt
echo $password >> /home/ubuntu/EPA-Project/creds.txt

# Download a WordPress database backup from an AWS S3 bucket
sudo aws s3 cp s3://brandscribe-backup/wordpress_dump.sql /tmp/wordpress_dump.sql

# If the backup is compressed, use gunzip to extract it (commented out in this script)
# sudo gunzip /tmp/wordpress_dump.sql.gz

# Create the database if it doesn't already exist
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"

# Create a new database user with the given username and password, allowing access from the frontend server
sudo mysql -e "CREATE USER IF NOT EXISTS '$username'@'FRONTEND_IP' IDENTIFIED BY '$password'"

# Grant all privileges on the database to the newly created user
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'FRONTEND_IP'"

# Apply privilege changes to take effect immediately
sudo mysql -e "FLUSH PRIVILEGES"

# Import the downloaded WordPress database dump into the newly created database
sudo mysql $username < /tmp/wordpress_dump.sql

# Remove the SQL file after import to avoid leaving sensitive data in the filesystem
sudo rm /tmp/wordpress_dump.sql

# This line (commented out) would upload the credentials file to an AWS S3 bucket for backup
# Ensure this is handled securely if needed
# sudo aws s3 cp /home/ubuntu/EPA-Project/creds.txt s3://brandscribe-backup
