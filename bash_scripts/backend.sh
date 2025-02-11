#!/bin/bash

sudo apt -y update && sudo apt -y upgrade

# Install the AWS CLI tool using Snap for managing AWS resources
sudo snap install aws-cli --classic

sudo apt -y install mariadb-server mariadb-client

sudo sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

sudo mysqladmin ping
sudo systemctl restart mariadb

# Database username and password variables
username=DB_USERNAME
password=DB_PASSWORD

echo $username > /home/ubuntu/EPA-Project/creds.txt
echo $password >> /home/ubuntu/EPA-Project/creds.txt

# Connect to S3 Bucket
sudo aws s3 cp s3://brandscribe-backup/wordpress_dump.sql /tmp/wordpress_dump.sql
#sudo gunzip /tmp/wordpress_dump.sql.gz

sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql -e "CREATE USER IF NOT EXISTS '$username'@'FRONTEND_IP' IDENTIFIED BY '$password'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* TO '$username'@'FRONTEND_IP'"
sudo mysql -e "FLUSH PRIVILEGES"
sudo mysql $username < /tmp/wordpress_dump.sql
sudo rm /tmp/wordpress_dump.sql

# This securely stores the credentials file in AWS S3 for later use or backup
sudo aws s3 cp /home/ubuntu/EPA-Project/creds.txt s3://brandscribe-backup
