#!/bin/bash

# Define ANSI color codes
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}Interactive Alias Addition${RESET}"
echo -e "${GREEN}---------------------------${RESET}"

# Create a list of existing aliases from ~/.zshrc
existing_aliases=($(grep -o "alias [^=]*=" ~/.zshrc | cut -d" " -f2 | cut -d"=" -f1))

while true; do
    read -p "Enter an alias name or 'e' to exit: " choice
    if [ "$choice" = "e" ]; then
        echo -e "${YELLOW}Exit,bay :)${RESET}"
        exit  # Exit the script
    elif [ -z "$choice" ]; then
        echo -e "${YELLOW}Please type something (alias name) before pressing Enter.${RESET}"
    else
        alias_name="$choice"

        while true; do
            read -p "Enter the command for '$alias_name': " alias_command
            if [ -z "$alias_command" ]; then
                echo -e "${YELLOW}Please enter a command for '$alias_name' before pressing Enter.${RESET}"
            else
                break  # Exit the loop when a valid command is provided
            fi
        done

        if [[ " ${existing_aliases[@]} " =~ " $alias_name " ]]; then
            # The alias already exists, so ask for confirmation to overwrite
            while true; do
                read -p "Alias '$alias_name' already exists. Overwrite it with the new command? (y/n): " confirm
                case "$confirm" in
                    [yY])
                        # Replace the existing alias in ~/.zshrc
                        sed -i "s/^alias $alias_name=.*$/alias $alias_name='$alias_command'/" ~/.zshrc
                        echo -e "${GREEN}Alias '$alias_name' updated in ~/.zshrc.${RESET}"
                        break ;;
                    [nN])
                        echo -e "${YELLOW}Alias '$alias_name' was not updated.${RESET}"
                        break ;;
                    *)
                        echo -e "${YELLOW}Invalid input. Please enter 'y' for yes or 'n' for no.${RESET}" ;;
                esac
            done
        else
            # The alias does not exist, so add it
            while true; do
                read -p "Add Alias '$alias_name' with command '$alias_command'? (y/n): " confirm
                case "$confirm" in
                    [yY])
                        # Append the alias to ~/.zshrc
                        echo "alias $alias_name='$alias_command'" >> ~/.zshrc
                        echo -e "${GREEN}Alias '$alias_name' added to ~/.zshrc.${RESET}"
                        existing_aliases+=("$alias_name")
                        break ;;
                    [nN])
                        echo -e "${YELLOW}Alias '$alias_name' was not added.${RESET}"
                        break ;;
                    *)
                        echo -e "${YELLOW}Invalid input. Please enter 'y' for yes or 'n' for no.${RESET}" ;;
                esac
            done
        fi

        while true; do
            read -p "Do you want to add more aliases? (y/n): " add_more
            case "$add_more" in
                [yY]) break ;;
                [nN]) 
                    echo -e "${YELLOW}Exit,bay :)${RESET}"
                    exit ;;
                *) echo -e "${YELLOW}Invalid input. Please enter 'y' for yes or 'n' for no.${RESET}" ;;
            esac
        done
    fi
done

# Source your zshrc file to apply the changes
source ~/.zshrc
echo -e "${YELLOW}Finished adding aliases. Exit,bay :).${RESET}"
