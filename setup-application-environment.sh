#!/bin/bash

# Path to the log file
LOG_FILE="/var/log/script_execution.log"

# Function to verify the exit status of the last executed command
verify_exit_status() {
    # $? holds the exit status of the last executed command
    if [ $? -ne 0 ]; then
        # If the exit status isn't zero, it means the command failed
        echo "Error: $1 did not complete successfully." | tee -a $LOG_FILE
        exit 1
    else
        # If the exit status is zero, the command was successful
        echo "$1 completed successfully." | tee -a $LOG_FILE
    fi
}

# Clear the contents of the log file at the start of the script
> $LOG_FILE

# Refresh the package list
echo "Executing apt update..." | tee -a $LOG_FILE
sudo apt -y update
# Confirm whether apt update was successful or not
verify_exit_status "apt update"

# Upgrade the installed packages
echo "Executing apt upgrade..." | tee -a $LOG_FILE
sudo apt -y upgrade
# Confirm whether apt upgrade was successful or not
verify_exit_status "apt upgrade"

# Clone the repository from GitHub
echo "Cloning the GitHub repository..." | tee -a $LOG_FILE
sudo git clone https://github.com/dannylanda/EPA.git /root/ai-content-application
# Confirm whether the git clone command was successful
verify_exit_status "git clone"

# Adjust permissions for the cloned repository
echo "Adjusting permissions for the repository..." | tee -a $LOG_FILE
sudo chmod -R 755 /root/ai-content-application
# Confirm whether chmod was successful
verify_exit_status "chmod"

# Execute the LEMP stack setup script
echo "Executing the lemp-setup.sh script..." | tee -a $LOG_FILE
sudo bash #!/bin/bash
sudo rm -rf /var/www/html
sudo apt -y install unzip
sudo wget -O /var/www/latest.zip https://wordpress.org/latest.zip
sudo unzip /var/www/latest.zip -d /var/www/
sudo rm /var/www/latest.zip
sudo mv /var/www/wordpress /var/www/html 

password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 25)
username=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 25)

echo $password > creds.txt
echo $username >> creds.txt
sudo mv creds.txt /root/ai-content-application/

# sudo mariadb -u root
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $username"
sudo mysql -e "CREATE USER IF NOT EXISTS $username@localhost identified by '$password'"
sudo mysql -e "GRANT ALL PRIVILEGES ON $username.* to $username@localhost"
sudo mysql -e "FLUSH PRIVILEGES"

# sudo wget -O /var/www/html/wp-config.php https://dannylandawordpress.s3.amazonaws.com/wp-config.php

sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php 
sudo chown -R www-data:www-data /var/www/html/

# Replace the placeholder 'password_here' in wp-config.php with the generated password.
sed -i "s/password_here/$password/g" /var/www/html/wp-config.php
sed -i "s/username_here/$username/g" /var/www/html/wp-config.php
sed -i "s/database_name_here/$username/g" /var/www/html/wp-config.php

# sudo cd /etc/nginx/conf.d/
# sudo touch wordpress.conf pull from s3bucketlemp-stack-setup.sh
# Confirm whether the setup script executed successfully
verify_exit_status "lemp-stack-setup.sh script"