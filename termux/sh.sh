#!/bin/bash

# Backup location
BACKUP_PATH="/storage/emulated/0/Download/termux-backup.tar.gz"
BACKUP_SIZE=$(du -sb /data/data/com.termux/files | awk '{print $1}')  # Get the size of the directories to back up

# Check if the storage folder exists, if not, run termux-setup-storage
if [ ! -d "$HOME/storage" ]; then
    echo "Storage folder not found. Setting up storage..."
    termux-setup-storage
else
    echo "Storage folder already exists. Skipping setup..."
fi

# Function to create a backup with progress bar
backup() {
    echo "Starting backup..."

    # Create the backup using pv for progress bar
    tar -cf - -C /data/data/com.termux/files ./home ./usr | pv -s $BACKUP_SIZE | gzip > $BACKUP_PATH

    if [ $? -eq 0 ]; then
        echo "Backup completed successfully and saved to $BACKUP_PATH"
    else
        echo "Error during backup. Please check the permissions."
    fi
}

# Function to restore the backup with progress bar
restore() {
    echo "Starting restore..."

    # Ensure that the backup file exists
    if [ ! -f $BACKUP_PATH ]; then
        echo "Backup file $BACKUP_PATH not found. Please ensure the backup file exists."
        exit 1
    fi

    # Get the size of the backup file
    BACKUP_FILE_SIZE=$(stat --printf="%s" $BACKUP_PATH)

    # Extract the backup using pv for progress bar
    pv -s $BACKUP_FILE_SIZE $BACKUP_PATH | gunzip | tar -xf - -C /data/data/com.termux/files --recursive-unlink --preserve-permissions

    if [ $? -eq 0 ]; then
        echo "Restore completed successfully."
        echo "Please close Termux and reopen it to apply the changes."
    else
        echo "Error during restore. Please check the permissions."
    fi
}

# Main menu
echo "Choose an option:"
echo "1. Backup"
echo "2. Restore"
read -p "Enter 1 or 2: " choice

case $choice in
    1)
        backup
        ;;
    2)
        restore
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac
