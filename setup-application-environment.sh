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
sudo bash /root/wordpress-project/lemp-setup.sh
# Confirm whether the setup script executed successfully
verify_exit_status "lemp-setup.sh script"