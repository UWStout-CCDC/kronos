#!/bin/bash
getCommandName="System Monitor"

script_path="./scripts/monitorScripts"

# Funtions to display login sessions
logins() {
    watch -x bash -c "display_options; $script_path/logins.sh"
}

# Function to display the current active connections
connections() {
    watch -x bash -c "display_options; $script_path/connections.sh"
}

processes() {
    watch -x bash -c "display_options; $script_path/processes.sh"
}

aide() {
    watch -x bash -c "display_options; $script_path/aide.sh"
}

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
    button_path="./scripts/monitorScripts"
    terminal_width=$(tput cols)
    separator=" | "

    for button_file in "$button_path"/*.sh; do
        button_name=$(basename "$button_file" .sh)
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
        "A")  # Up arrow key
            selected=$(( (selected - 2 + 3) % 3 + 1 ))
            ;;
        "B")  # Down arrow key
            selected=$(( (selected % 3) + 1 ))
            ;;
        "")
                run "$selected"
            ;;
        *)
            # Ignore other keys
            ;;
    esac
}

# Function to run the selected function
run() {
    case "$1" in
        1)
            running_function="aide"
            aide & get_input
            ;;
        2)
            running_function="connections"
            connections & get_input
            ;;
        3)
            running_function="logins"
            logins & get_input
            ;;
        4)
            running_function="processes"
            processes & get_input
            ;;
    esac
}

# Call the display_menu function when the script is executed
tput civis
display_menu