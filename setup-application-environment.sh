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