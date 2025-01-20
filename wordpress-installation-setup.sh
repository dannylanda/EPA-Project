# #!/bin/bash 

# # Entering the html directory 
# cd /var/www/html

# # Installing the unzip package
# sudo apt -y install unzip 

# # Install/Unzip/Remove WordPress
# sudo wget https://wordpress.org/latest.zip 
# sudo unzip latest.zip  
# sudo rm latest.zip 

# # Generate password for use in WordPress Database
# username=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 25)
# password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 25)

# echo $username >> creds.txt
# echo $password > creds.txt

# # Create a MariaDB Database and a User for the WordPress Site  
# sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
# sudo mysql -e "CREATE USER $username@localhost identified by '$password'"
# sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* to $username@localhost"
# sudo mysql -e "FLUSH PRIVILEGES" # Applies everything you've done 

# sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
# sudo chmod 640 /var/www/html/wp-config.php 
# sudo chown -R www-data:www-data /var/www/html/wordpress

# sed -i "s/password_here/$password/g" /var/www/html/wp-config.php
# sed -i "s/username_here/$username/g" /var/www/html/wp-config.php
# sed -i "s/database_name_here/$username/g" /var/www/html/wp-config.php

############################################################################

#!/bin/bash 

# Entering the html directory 
cd /var/www/html

# Install AWS CLI tools
snap install aws-cli --classic

# Installing required packages
sudo apt -y install unzip

# Install/Unzip/Remove WordPress
sudo wget https://wordpress.org/latest.zip 
sudo unzip latest.zip  
sudo rm latest.zip 

# Generate password for use in WordPress Database
username=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 25)
password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 25)

echo $username > root/EPA-Project/creds.txt
echo $password >> root/EPA-Project/creds.txt

# Connect to S3 Bucket
aws s3 cp s3://brandscribe-backup/wordpress_dump.sql.gz /tmp/wordpress_dump.sql.gz
sudo gunzip /tmp/wordpress_dump.sql.gz
password=$(head -n 1 /root/EPA-Project/creds.txt)
username=$(tail -n 1 /root/EPA-Project/creds.txt)
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql $username < /tmp/wordpress_dump.sql
sudo rm /tmp/wordpress_dump.sql

# Set up the WordPress config file
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo chmod 640 /var/www/html/wordpress/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/wordpress

# Update wp-config.php with the database credentials
sed -i "s/password_here/$password/g" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$username/g" /var/www/html/wordpress/wp-config.php
sed -i "s/database_name_here/$username/g" /var/www/html/wordpress/wp-config.php
