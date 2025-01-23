#!/bin/bash

apt -y update && apt -y upgrade

# Install the AWS CLI tool using Snap for managing AWS resources
snap install aws-cli --classic

apt install mariadb-server mariadb-client -y

sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl restart mariadb

password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 25)
username=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 25)

echo $password > creds.txt
echo $username >> creds.txt

# Connect to S3 Bucket
aws s3 cp s3://brandscribe-backup/wordpress_dump.sql.gz /tmp/wordpress_dump.sql.gz
sudo gunzip /tmp/wordpress_dump.sql.gz
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql $username < /tmp/wordpress_dump.sql
sudo rm /tmp/wordpress_dump.sql

# Update wp-config.php with the database credentials
sed -i "s/password_here/$password/g" /var/www/html/wp-config.php
sed -i "s/username_here/$username/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/$username/g" /var/www/html/wp-config.php

# This securely stores the credentials file in AWS S3 for later use or backup
aws s3 cp creds.txt s3://brandscribe-backup/
