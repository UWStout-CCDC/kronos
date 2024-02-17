#!/bin/bash
getCommandName="System Monitor"

script_path="/ccdc/scripts/monitorScripts"

# Array to store the available buttons
buttons=()

# Function to display the menu with dynamically generated buttons
display_menu() {
    clear
    
    # Highlight the first button initially
    selected=1
    
    while true; do
        display_options
        
        get_input

        clear
    done
}

# Display runnable functions
display_options() {
    echo -e "Options Menu:"
    echo -e "-------------"

    button_index=1
    button_path="/ccdc/scripts/monitorScripts"
    terminal_width=$(tput cols)
    separator=" | "

    for button_file in "$button_path"/*.sh; do
        button_name=$(basename "$button_file" .sh)
        buttons+=("$button_name") # Add button to the array

        if [ "$selected" == "$button_index" ]; then
            echo -e "\e[7m$button_index) $button_name\e[0m\c"
        else
            echo -e "$button_index) $button_name\c"
        fi
        button_index=$((button_index + 1))

        # Check if there is enough space for the next button
        button_length=$(( ${#button_name} + ${#button_index} + ${#separator} ))
        if [ $((button_length + ${#separator})) -gt $((terminal_width - 1)) ]; then
            echo "" # Switch to a new line
        else
            echo -e "$separator\c" # Add separator
        fi
    done

    echo "" # Add a new line after the options
    echo "0) Exit"
    echo "=-=-=-=-=-=-="
}
typeset -fx display_options

# Function to get user input
get_input() {
    read -s -n 1 key

    case "$key" in
        "0") # Exit key
            clear
            echo "Exiting..."
            tput cnorm
            killall watch
            exit 1
            ;;
        [1-9]) # Number key navigation
            if [[ -n "$running_function" ]]; then
                killall watch
            fi
            selected="$key"
            run "$key"
            ;;
        "D")  # Left arrow key
            selected=$(( (selected - 2 + ${#buttons[@]}) % ${#buttons[@]} + 1 ))
            ;;
        "C")  # Right arrow key
            selected=$(( (selected % ${#buttons[@]}) + 1 ))
            ;;
        "")
            run "$selected"
            ;;
        *)
            # Ignore other keys
            ;;
    esac
}

# Function to run the selected function dynamically
run() {
    selected_button="${buttons[$1-1]}"
    running_function="$selected_button"
    watch -x bash -c "display_options; "$script_path"/"$selected_button".sh" & get_input
}

# Function to get the scripts
# Add a wget in the same style but changing the script name to add more scripts as needed
# Note: new script will need to be in the monitorScripts folder of the github
# Make sure to add a chmod +x to the script as done below to any new scripts or it will have permission issues
getScripts() {
    if [ ! -d "$script_path" ]; then
        mkdir -p "$script_path"
    fi

    wget -O $script_path/aide.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/aide.sh
    wget -O $script_path/aliases.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/aliases.sh
    wget -O $script_path/connections.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/connections.sh
    wget -O $script_path/cron.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/cron.sh
    wget -O $script_path/fileChanges.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/fileChanges.sh
    wget -O $script_path/logins.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/logins.sh
    wget -O $script_path/packages.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/packages.sh
    wget -O $script_path/processes.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/processes.sh
    wget -O $script_path/users.sh https://raw.githubusercontent.com/UWStout-CCDC/kronos/main/Linux/General/monitorScripts/users.sh

    chmod +x $script_path/aide.sh
    chmod +x $script_path/aliases.sh
    chmod +x $script_path/connections.sh
    chmod +x $script_path/cron.sh
    chmod +x $script_path/fileChanges.sh
    chmod +x $script_path/logins.sh
    chmod +x $script_path/packages.sh
    chmod +x $script_path/processes.sh
    chmod +x $script_path/users.sh
}

# Call the display_menu function when the script is executed
tput civis

if [ ! -f "temp2" ] && [ ! -f "temp3" ]; then
    md5sum /etc/passwd /etc/group /etc/profile /etc/sudoers /etc/hosts /etc/ssh/ssh_config /etc/ssh/sshd_config > temp2
    ls -a /etc/ /usr/ /sys/ /home/ /bin/ /etc/ssh/ >> temp2
fi

#if script_path is empty, then get the scripts
if [ -z "$(ls -A $script_path)" ]; then
    echo -e "\e[32mScripts not found, getting scripts\e[0m"
    getScripts
fi

# check which package manager is installed and install net-tools and psmisc if not installed
if [ -z "$(which apt)" ]; then
    if [ -z "$(which yum)" ]; then
        if [ -z "$(which dnf)" ]; then
            echo -e "\e[31mNo package manager found\e[0m"
        else
            if [ -z "$(which netstat)" ]; then
                dnf install net-tools -y
            fi
            if [ -z "$(which pstree)" ]; then
                dnf install psmisc -y
            fi
            if [ -z "$(which aide)" ]; then
                dnf install aide -y
            fi
        fi
    else
        if [ -z "$(which netstat)" ]; then
            yum install net-tools -y
        fi
        if [ -z "$(which pstree)" ]; then
            yum install psmisc -y
        fi
        if [ -z "$(which aide)" ]; then
            yum install aide -y
        fi
    fi
else
    if [ -z "$(which netstat)" ]; then
        apt install net-tools -y
    fi
    if [ -z "$(which pstree)" ]; then
        apt install psmisc -y
    fi
    if [ -z "$(which aide)" ]; then
        apt install aide -y
    fi
fi

# If /var/lib/aide/aide.db.gz does not exist
if [ ! -f "/var/lib/aide/aide.db.gz" ]; then
    aide --init
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
fi

display_menu