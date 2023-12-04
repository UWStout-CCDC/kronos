#!/bin/bash
tput civis

highlight_color=$(tput smso | sed -n l)
highlight=${highlight_color::-1}

scriptLocation="/ccdc/scripts/"

commands=("peer" "org" "channel" "chaincode")
numCommands=$((${#commands[@]} + 2))


#Print the Loading Screen
loadingScreen() {
    clear

    startLine=$((($(tput lines) - 15) / 2 - 7))                                                                          
                                                                                                             
    center_text $(($startLine + 0)) "KKKKKKKKK    KKKKKKK                                                                                         "
    center_text $(($startLine + 1)) "K:::::::K    K:::::K                                                                                         "
    center_text $(($startLine + 2)) "K:::::::K    K:::::K                                                                                         "
    center_text $(($startLine + 3)) "K:::::::K   K::::::K                                                                                         "
    center_text $(($startLine + 4)) "KK::::::K  K:::::KKKrrrrr   rrrrrrrrr      ooooooooooo   nnnn  nnnnnnnn       ooooooooooo       ssssssssss   "
    center_text $(($startLine + 5)) "  K:::::K K:::::K   r::::rrr:::::::::r   oo:::::::::::oo n:::nn::::::::nn   oo:::::::::::oo   ss::::::::::s  "
    center_text $(($startLine + 6)) "  K::::::K:::::K    r:::::::::::::::::r o:::::::::::::::on::::::::::::::nn o:::::::::::::::oss:::::::::::::s "
    center_text $(($startLine + 7)) "  K:::::::::::K     rr::::::rrrrr::::::ro:::::ooooo:::::onn:::::::::::::::no:::::ooooo:::::os::::::ssss:::::s"
    center_text $(($startLine + 8)) "  K:::::::::::K      r:::::r     r:::::ro::::o     o::::o  n:::::nnnn:::::no::::o     o::::o s:::::s  ssssss "
    center_text $(($startLine + 9)) "  K::::::K:::::K     r:::::r     rrrrrrro::::o     o::::o  n::::n    n::::no::::o     o::::o   s::::::s      "
    center_text $(($startLine + 10)) "  K:::::K K:::::K    r:::::r            o::::o     o::::o  n::::n    n::::no::::o     o::::o      s::::::s   "
    center_text $(($startLine + 11)) "KK::::::K  K:::::KKK r:::::r            o::::o     o::::o  n::::n    n::::no::::o     o::::ossssss   s:::::s "
    center_text $(($startLine + 12)) "K:::::::K   K::::::K r:::::r            o:::::ooooo:::::o  n::::n    n::::no:::::ooooo:::::os:::::ssss::::::s"
    center_text $(($startLine + 13)) "K:::::::K    K:::::K r:::::r            o:::::::::::::::o  n::::n    n::::no:::::::::::::::os::::::::::::::s "
    center_text $(($startLine + 14)) "K:::::::K    K:::::K r:::::r             oo:::::::::::oo   n::::n    n::::n oo:::::::::::oo  s:::::::::::ss  "
    center_text $(($startLine + 15)) "KKKKKKKKK    KKKKKKK rrrrrrr               ooooooooooo     nnnnnn    nnnnnn   ooooooooooo     sssssssssss    "

    tput cup $(($startLine + 20)) $(( ($(tput cols) - 7) /2 ))
    printf "Loading"
}


#Get the list of commands that are in the script location
getCommandList() {
    commandSH=()
    commandSH+=(`ls $scriptLocation | grep .sh`)

    for i in "${!commandSH[@]}"; do
        source $scriptLocation${commandSH[$i]}
        commandNames+=("$(getCommandName)")
        printf "."
    done

    commands=("${commandNames[@]}")
    numCommands=$((${#commands[@]} + 2))
}


# Function to calculate the center position
center_text(){
    row=$1
    text=$2

    tput sc
    tput cup $row $(( ($(tput cols) - ${#text}) /2 ))
    if [[ $3 == true ]]; then
        echo -e $highlight"$text"
    else
        echo -e "$text"
    fi
    
    tput rc
}


# Function to display the menu screen
drawMenu() {
    #clear
    printf "%$(tput cols)s" | tr " " "-"

    center_text 4 "+----------------------------------+"
    center_text 5 "|  _  __                           |"
    center_text 6 "| | |/ /                           |"
    center_text 7 "| | ' / _ __ ___  _ __   ___  ___  |"
    center_text 8 "| |  < | '__/ _ \| '_ \ / _ \/ __| |"
    center_text 9 "| | . \| | | (_) | | | | (_) \__ \ |"
    center_text 10 "| |_|\_\_|  \___/|_| |_|\___/|___/ |"
    center_text 11 "|                                  |"
    center_text 12 "|                                  |"
    center_text 13 "+----------------------------------+"
   
}


# Function to display the menu with highlighting (it grabs the command names from when it checked the scripts)
drawSelection() {
    installSelection=$(($numCommands - 1))

    for i in "${!commands[@]}"; do
            #[[ $selection == $(($i + 1)) ]] && center_text $((14 + i)) "[ Menu Function $(($i + 1)) ]" true || center_text $((14 + i)) "  Menu Function $(($i + 1))  "
            [[ $selection == $(($i + 1)) ]] && center_text $((14 + i)) "[ ${commandNames[$i]} ]" true || center_text $((14 + i)) "     ${commandNames[$i]}     "
    done

    [[ $selection == $installSelection ]] && center_text $((15 + ${#commands[@]})) "[ Install Scripts ]" true || center_text $((15 + ${#commands[@]})) "     Install Scripts      "
    [[ $selection == $numCommands ]] && center_text $((16 + ${#commands[@]})) "[ EXIT ]" true || center_text $((16 + ${#commands[@]})) "     EXIT     "
}

# Function to get user input
get_input() {
    read -rsn1 key
    case $key in
        "A") # Up arrow key
            #selection=$(( (selection - 2 + $numCommands + 0) % (${#commands[@]} + 2) + 0 ))
            selection=$(( (selection - 2 + $numCommands + 0) % $numCommands + 1 ))
            ;;
        "B") # Down arrow key
            selection=$(( selection % $numCommands + 1 ))
            ;;
        "")
            # Enter key
            break
            ;;
    esac
}


# Main loop
loadingScreen
getCommandList
sleep 1
selection=1
clear
while true; do
    drawMenu
    while true; do 
        drawSelection
        tput cup $(( $(tput lines) - 1 )) 0
        get_input

        case $key in
            "A" | "B")
                # User pressed arrow keys, update the menu
                ;;
        esac

    done

    # Execute the selected option
    tput cup $(( $(tput lines) - 3 )) 0
    if [[ $selection == $numCommands ]]; then
        tput cnorm
        exit
    elif [[ $selection == $(($numCommands - 1)) ]]; then
        echo "Installing Scripts Place Holder"
        tput cup 0 0
    else
        clear
        tput cup $(( $(tput lines) - 4 )) 0
        echo "You selected Option $scriptLocation${commandSH[$(($selection - 1))]}"
        echo "$selection"
        read -n 1 -s -r -p "Press any key to continue..."
        clear
        tput cup 0 0
    fi
done
