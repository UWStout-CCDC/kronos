#!/bin/bash
getCommandName="System Monitor"

# Path to the folder containing scripts
script_folder="./scripts/monitorScripts/"

# Function to display the menu with dynamically generated buttons
display_menu() {
    clear
    
    # Dynamically generate buttons based on scripts in the folder
    buttons=("$script_folder"/*.sh)
    
    # Highlight the first button initially
    selected=1
    
    while true; do
        display_options

        get_input

        # Clear the screen before displaying the menu again
        clear
    done
}

# Display runnable scripts 
display_options() {
    echo "Press 0 to exit"
    for ((i=0; i<${#buttons[@]}; i++)); do
        button_number=$((i + 1))
        button_name=$(basename "${buttons[i]}")
        
        if [ "$button_number" -eq "$selected" ]; then
            echo -e "\e[1;33mPress $button_number for $button_name\e[0m"
        else
            echo "Press $button_number for $button_name"
        fi
    done
}

# Function to get user input - W.I.P
get_input() {
    read -s -n 1 key

        case "$key" in
            "0") # Exit key
                clear
                echo "Exiting..."
                tput cnorm
                exit 1
                ;;
            [1-9]) # Number key navigation
                run_script "$key"
                read -n 1 -p "Press any key to continue..."
                ;;
            "A")  # Up arrow key
                selected=$(( (selected - 2 + ${#buttons[@]}) % ${#buttons[@]} + 1 ))
                ;;
            "B")  # Down arrow key
                selected=$(( (selected % ${#buttons[@]}) + 1 ))
                ;;
            "")
                run_script "$selected"
                read -n 1 -p "Press any key to continue..."
                ;;
            *)
                # Ignore other keys
                ;;
        esac
}

# Function to run the selected script
run_script() {
    script_path="${buttons[$1 - 1]}"
    clear
    echo "Running script: $script_path"
    bash "$script_path"
}

# Call the display_menu function when the script is executed
tput civis
display_menu


#TODO:
#-Create monitor script with interactive panels that dynamically update
# Need to create a panel at the bottom/top/side of terminal that has options for what to monitor
# Each panel will update itself when selected and continously update while open on an interval
# Each panel will also make use of less to allow user to navigate the output
# Take inspiration from monitor.sh but rewrite it