#!/bin/bash

# Log file path
LOG_FILE="/var/log/script_execution.log"

# Function to check the exit status of the last executed command
check_exit_status() {
    # $? contains the exit status of the last executed command
    if [ $? -ne 0 ]; then
        # If the exit status is non-zero, it means the command failed
        echo "Error: $1 failed." | tee -a $LOG_FILE
        exit 1
    else
        # If the exit status is zero, it means the command succeeded
        echo "$1 succeeded." | tee -a $LOG_FILE
    fi
}

# Clear the log file at the beginning of the script
> $LOG_FILE

# Update package lists
echo "Running apt update..." | tee -a $LOG_FILE
sudo apt -y update
# Check if the apt update command succeeded or failed
check_exit_status "apt update"

# Upgrade installed packages
echo "Running apt upgrade..." | tee -a $LOG_FILE
sudo apt -y upgrade
# Check if the apt upgrade command succeeded or failed
check_exit_status "apt upgrade"

# Clone the GitHub repository
echo "Cloning GitHub repository..." | tee -a $LOG_FILE
sudo git clone https://github.com/dannylanda/EPA-Project.git /root/EPA-Project
# Check if the git clone command succeeded or failed
check_exit_status "git clone"

# Change permissions of the cloned repository
echo "Changing permissions of the cloned repository..." | tee -a $LOG_FILE
sudo chmod -R 755 /root/EPA-Project/
# Check if the chmod command succeeded or failed
check_exit_status "chmod"

# Run the setup script
echo "Running lemp-setup-setup.sh script..." | tee -a $LOG_FILE
sudo bash /root/EPA-Project/lemp-stack-setup.sh
# Check if the setup script execution succeeded or failed
check_exit_status "lemp-stack-setup.sh script"