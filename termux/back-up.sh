#!/bin/bash

# Define backup and restore locations
BACKUP_PATH="/storage/emulated/0/Download/backup.tar.xz"
GPG_BACKUP_PATH="/storage/emulated/0/Download/backup.tar.xz.gpg"
BACKUP_DIR="$HOME"
BACKUP_SIZE=$(du -sb /data/data/com.termux/files | awk '{print $1}')  # Get the size of the directories to back up

# Check if the storage folder exists, if not, run termux-setup-storage
if [ ! -d "$HOME/storage" ]; then
    echo "Storage folder not found. Setting up storage..."
    termux-setup-storage
else
    echo "Storage folder already exists. Skipping setup..."
fi

# Function to create backup with progress bar
backup() {
    echo "Starting backup..."

    # Ask user for compression type
    echo "Choose compression format:"
    echo "1. gzip (.tar.gz)"
    echo "2. xz (.tar.xz)"
    echo "3. No compression (.tar)"
    read -p "Enter 1, 2, or 3: " compression_choice

    case $compression_choice in
        1)
            BACKUP_PATH="/storage/emulated/0/Download/backup.tar.gz"
            tar -cf - -C /data/data/com.termux/files ./home ./usr | pv -s $BACKUP_SIZE | gzip > $BACKUP_PATH
            ;;
        2)
            BACKUP_PATH="/storage/emulated/0/Download/backup.tar.xz"
            tar -cf - -C /data/data/com.termux/files ./home ./usr | pv -s $BACKUP_SIZE | xz > $BACKUP_PATH
            ;;
        3)
            BACKUP_PATH="/storage/emulated/0/Download/backup.tar"
            tar -cf - -C /data/data/com.termux/files ./home ./usr | pv -s $BACKUP_SIZE > $BACKUP_PATH
            ;;
        *)
            echo "Invalid choice. Using default compression (xz)."
            BACKUP_PATH="/storage/emulated/0/Download/backup.tar.xz"
            tar -cf - -C /data/data/com.termux/files ./home ./usr | pv -s $BACKUP_SIZE | xz > $BACKUP_PATH
            ;;
    esac

    # Optionally, encrypt the backup with GPG
    read -p "Do you want to encrypt the backup with GPG? (y/n): " encrypt_choice
    if [ "$encrypt_choice" == "y" ]; then
        echo "Encrypting backup..."
        gpg --symmetric --output $GPG_BACKUP_PATH $BACKUP_PATH
        echo "Backup encrypted and saved to $GPG_BACKUP_PATH"
        rm $BACKUP_PATH  # Remove unencrypted backup
    else
        echo "Backup completed and saved to $BACKUP_PATH"
    fi
}

# Function to restore backup with progress bar
restore() {
    echo "Starting restore..."

    # Ensure that the backup file exists
    if [ ! -f $BACKUP_PATH ]; then
        echo "Backup file $BACKUP_PATH not found. Please ensure the backup file exists."
        exit 1
    fi

    # Get the size of the backup file for progress bar
    BACKUP_FILE_SIZE=$(stat --printf="%s" $BACKUP_PATH)

    # Ask user if they have an encrypted backup
    read -p "Do you have an encrypted backup (y/n)? " encrypted_choice
    if [ "$encrypted_choice" == "y" ]; then
        export GPG_TTY=$(tty)
        echo "Decrypting backup..."
        pv -s $BACKUP_FILE_SIZE $GPG_BACKUP_PATH | gpg --decrypt | termux-restore -
        echo "Restore completed from encrypted backup."
    else
        pv -s $BACKUP_FILE_SIZE $BACKUP_PATH | tar -xf - -C /data/data/com.termux/files --recursive-unlink --preserve-permissions
        echo "Restore completed from unencrypted backup."
    fi

    echo "Restarting Termux to apply restore..."
    # Ask user to restart Termux for changes to take effect
    read -p "Please restart Termux to complete restore. Press [Enter] to continue."
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
