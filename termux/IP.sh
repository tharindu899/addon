#!/bin/bash

# Prompt for custom user, IP, and alias if not provided as arguments
if [ $# -lt 3 ]; then
    read -p "Enter the remote username: " REMOTE_USER
    read -p "Enter the remote IP address: " REMOTE_HOST
    read -p "Enter the custom alias name: " ALIAS_NAME
else
    REMOTE_USER="$1"
    REMOTE_HOST="$2"
    ALIAS_NAME="$3"
fi

# Define the SSH key file location
SSH_KEY_PATH="$HOME/.ssh/id_rsa"
SSH_KEY_PUB_PATH="$SSH_KEY_PATH.pub"

# Check if the SSH key already exists
if [ ! -f "$SSH_KEY_PUB_PATH" ]; then
    echo "SSH key not found. Generating a new key..."
    
    # Generate the SSH key if not present
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" 

    if [ $? -ne 0 ]; then
        echo "Failed to generate SSH key."
        exit 1
    fi
else
    echo "SSH key found. Proceeding with ssh-copy-id."
fi

# Copy the SSH key to the remote server
echo "Copying SSH key to remote server $REMOTE_USER@$REMOTE_HOST..."
ssh-copy-id -i "$SSH_KEY_PUB_PATH" "$REMOTE_USER@$REMOTE_HOST"

if [ $? -eq 0 ]; then
    echo "SSH key copied successfully to $REMOTE_USER@$REMOTE_HOST."
else
    echo "Failed to copy SSH key to remote server."
    exit 1
fi

# Check if the alias already exists in .zshrc
if grep -q "alias $ALIAS_NAME" "$HOME/.zshrc"; then
    echo "Alias '$ALIAS_NAME' already exists in .zshrc. Skipping alias creation."
else
    echo "Creating alias '$ALIAS_NAME' for $REMOTE_USER@$REMOTE_HOST..."

    # Add the alias to .zshrc
    echo "alias $ALIAS_NAME='ssh ${REMOTE_USER}@${REMOTE_HOST}'" >> "$HOME/.zshrc"
    
    if [ $? -eq 0 ]; then
        echo "Alias '$ALIAS_NAME' created successfully."
    else
        echo "Failed to create alias."
        exit 1
    fi
fi

# Reload .zshrc to apply the alias
source "$HOME/.zshrc"

echo "Setup complete. You can now use '$ALIAS_NAME' to SSH into the remote server."
