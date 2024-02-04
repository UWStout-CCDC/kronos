#!/bin/bash

currentDirectory=$(pwd)

highlight_color=$(tput smso | sed -n l)
highlight=${highlight_color::-1}

scriptLocation="/ccdc/scripts/"
githubURL="https://raw.githubusercontent.com/UWStout-CCDC/kronos/master"
# scriptLocation="/ccdc/scripts/linux/kronos/"

#Print the Loading Screen
loadingScreen() {
    clear

    startLine=$((($(tput lines) - 15) / 2 - 7))
    if [[ $(tput cols) > 110 ]]; then
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
    fi

    tput cup $(($startLine + 20)) $(( ($(tput cols) - 7) /2 ))
    printf "Loading"
}


#Get the list of commands that are in the script location
getCommandList() {
    commandSH=()
    commandSH+=(`ls $scriptLocation | grep .sh`)
    commandNames=()
    kronosNeedsInit=false

    if [[ -d $scriptLocation ]]; then
        for i in "${!commandSH[@]}"; do
            # source $scriptLocation${commandSH[$i]}
            #get the command name from the script and put it into an array to be used later, to get the name of the command use getCommandName $scriptLocation${commandSH[$i]}
            commandNames+=("$(getCommandName $scriptLocation${commandSH[$i]})")
        done
    # else
        # commandNames+=("Initialize Kronos")
        # kronosNeedsInit=true
        # export kronosNeedsInit
    fi

    if [[ ${#commandNames[@]} == 0 ]]; then
        commandNames+=("Initialize Kronos")
        kronosNeedsInit=true
    fi
   
    commands=("${commandNames[@]}")
    if [[ $kronosNeedsInit == true ]]; then
        numCommands=$((${#commands[@]} + 1))
    else
        numCommands=$((${#commands[@]} + 2))
    fi
    
}

getCommandName() {
    file=$1

    # commandName=$(cat $file | grep "getCommandName=" | sed 's/getCommandName=//g')
    commandName=$(cat $1 | grep "getCommandName=" -m 1 | awk -F"=" '{print $2}' | sed 's/\"//g')
    echo $commandName
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

triColomnText(){
    row=$1
    text=$2
    text2=$3
    text3=$4
    selected=$5

    tput sc

    if [[ $selected == 1 ]]; then
        echo -e $highlight
    fi
    tput cup $row $(( ($(tput cols) / 4 * 1 ) - ${#text} /2 ))
    echo -e "$text"
    echo -e $NC

    if [[ $selected == 2 ]]; then
        echo -e $highlight
    fi
    tput cup $row $(( ($(tput cols) / 4 * 2 ) - ${#text2} /2 ))
    echo -e "$text2"
    echo -e $NC

    if [[ $selected == 3 ]]; then
        echo -e $highlight
    fi
    tput cup $row $(( ($(tput cols) / 4 * 3 ) - ${#text3} /2 ))
    echo -e "$text3"
    echo -e $NC

    tput rc
}


# Function to display the menu screen
drawLogo() {                       

    #BLUE=$(tput setaf 183)
    #WHITE=$(tput setaf 7)
    NC='\033[0m'
    BLUE='\033[0;34m'

    echo -e $BLUE

    center_text 4 "                              "
    center_text 5 "    __ __                     "
    center_text 6 "   / //________  ___ ___  ___ "
    center_text 7 "  / ,< / __/ _ \/ _ / _ \(_-< "
    center_text 8 " /_/|_/_/  \___/_//_\___/___/ "
    center_text 9 "                              "
    
    echo -e $NC
}

#Function to draw stars randmly on the screen
drawStars() {
    #BLUE=$(tput setaf 183)
    #WHITE=$(tput setaf 7)
    NC='\033[0m'
    CYAN='\033[0;36m'

    echo -e $CYAN

    for i in {1..100}; do
        tput cup $((RANDOM % $(($(tput lines) - 1)))) $((RANDOM % $(tput cols)))
        echo "."
    done

    echo -e $NC
}



# Function to display the menu with highlighting (it grabs the command names from when it checked the scripts)
drawSelection() {
    installSelection=$(($numCommands - 1))


    for i in "${!commands[@]}"; do
            
            [[ $selection == $(($i + 1)) ]] && center_text $((15 + i)) "[ ${commandNames[$i]} ]" true || center_text $((15 + i)) "     ${commandNames[$i]}     "
    done
    if [[ $kronosNeedsInit != true ]]; then
        [[ $selection == $installSelection ]] && center_text $((16 + ${#commands[@]})) "[ Install Scripts ]" true || center_text $((16 + ${#commands[@]})) "      Install Scripts      "
    fi
    [[ $selection == $numCommands ]] && center_text $((17 + ${#commands[@]})) "[ EXIT ]" true || center_text $((17 + ${#commands[@]})) "     EXIT     "
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
            ;;
    esac
}

kronosInit() {
    echo "Initializing Kronos"
    # First we will check if the directory exists, if it does not we will create it
    if [[ ! -d $scriptLocation ]]; then
        mkdir -p $scriptLocation
    fi
    # Install the init script from github

    wget -q $githubURL/Linux/General/init.sh --directory-prefix "$scriptLocation" --show-progress || echo "Failed to install Kronos Init"
    # Install the init script from github
    $kronosNeedsInit = false
}

# Function to return the install text
# Outputs to a variable returnInstallOutput
returnInstallText() {
    scriptPending=$1
    scriptName=$2

    if [[ $scriptName == "" ]]; then
        returnInstallOutput=""
    elif [[ $scriptPending == "true" ]]; then
        returnInstallOutput="[X] ${scriptName}"
    else
        returnInstallOutput="[ ] ${scriptName}"
    fi
}


# Function to draw the install page
drawInstallPage(){
    page=$1
    section=$2
    selection=$3

    # Draw the page number
    tput cup 0 $(( $(tput cols) / 2 - 5 ))
    echo "Page $page"
    # Draw the controls
    tput cup 0 $(( $(tput cols) - 25 ))
    echo "Arrow Keys to Navigate"
    tput cup 1 $(( $(tput cols) - 25 ))
    echo "Space to Select"
    tput cup 2 $(( $(tput cols) - 25 ))
    echo "Enter to Install Selected"
    tput cup 3 $(( $(tput cols) - 25 ))
    echo "Q to Quit"

    # Draw the page headers
    if [[ $page == 1 ]]; then
        triColomnText 5 "  General  " "  E-Comm  " "Splunk  "
    elif [[ $page == 2 ]]; then
        triColomnText 5 "  Injects  " "  Webserver  " "  Email  "
    fi

    # Find the largest section and store the length of it
    if [[ $page == 1 ]]; then
        if [[ ${#generalName[@]} > ${#ecommName[@]} ]]; then
            if [[ ${#generalName[@]} > ${#splunkName[@]} ]]; then
                largestSection=${#generalName[@]}
            else
                largestSection=${#splunkName[@]}
            fi
        else
            if [[ ${#ecommName[@]} > ${#splunkName[@]} ]]; then
                largestSection=${#ecommName[@]}
            else
                largestSection=${#splunkName[@]}
            fi
        fi
    elif [[ $page == 2 ]]; then
        if [[ ${#injectsName[@]} > ${#webserverName[@]} ]]; then
            if [[ ${#injectsName[@]} > ${#emailName[@]} ]]; then
                largestSection=${#injectsName[@]}
            else
                largestSection=${#emailName[@]}
            fi
        else
            if [[ ${#webserverName[@]} > ${#emailName[@]} ]]; then
                largestSection=${#webserverName[@]}
            else
                largestSection=${#emailName[@]}
            fi
        fi
    fi

    # Draw the script names
    # If the script is pending install, draw it with an [*] in front of it else draw it with an [ ] in front of it
    # If the script is selected highlight it
    for (( i=0; i<$largestSection; i++ )); do
        if [[ $page == 1 ]]; then
            returnInstallText ${generalPending[$i]} "${generalName[$i]}"
            generalText=$returnInstallOutput
            returnInstallText ${ecommPending[$i]} "${ecommName[$i]}"
            ecommText=$returnInstallOutput
            returnInstallText ${splunkPending[$i]} "${splunkName[$i]}"
            splunkText=$returnInstallOutput

            if [[ $selection == $(($i + 1)) ]]; then
                triColomnText $(( 7 + $i )) "${generalText}" "${ecommText}" "${splunkText}" $section
            else
                triColomnText $(( 7 + $i )) "${generalText}" "${ecommText}" "${splunkText}"
            fi
        elif [[ $page == 2 ]]; then
            returnInstallText ${injectsPending[$i]} "${injectsName[$i]}"
            injectsText=$returnInstallOutput
            returnInstallText ${webserverPending[$i]} "${webserverName[$i]}"
            webserverText=$returnInstallOutput
            returnInstallText ${emailPending[$i]} "${emailName[$i]}"
            emailText=$returnInstallOutput

            if [[ $selection == $(($i + 1)) ]]; then
                triColomnText $(( 7 + $i )) "${injectsText}" "${webserverText}" "${emailText}" $section
            else
                triColomnText $(( 7 + $i )) "${injectsText}" "${webserverText}" "${emailText}"
            fi
        fi
    done

}


# Function to install scripts
scriptInstall() {
    # The install will have a total of 6 columns, they are in order as follows 
    # General | E-Comm | Splunk | Injects | Webserver | Email
    # The script will only show 3 at a time, either left half or right half
    # The user will be able to scroll through the options and select which ones they want to install
    # Marking the ones they want to install with an X and install when they press enter
    # Compatibilites will for now be checked by the script itself, but will be moved to the install script

    # Clear all of the old arrays
    generalLocation=()
    generalName=()
    generalPending=()
    ecommLocation=()
    ecommName=()
    ecommPending=()
    splunkLocation=()
    splunkName=()
    splunkPending=()
    injectsLocation=()
    injectsName=()
    injectsPending=()
    webserverLocation=()
    webserverName=()
    webserverPending=()
    emailLocation=()
    emailName=()
    emailPending=()
    

    # https://githubusercontent.com/UWStout-CCDC/kronos-linux/master/ = Default Prefix

    # TODO:
    # At some point the names of the already installed scripts need to be found so the script can mark them as installed so they dont show up in the install list

    # First the script will have to download a list of all the scripts that are available to install
    wget -q $githubURL/scripts.list -O /tmp/Scripts.txt

    # Then it will have to parse the file and get the names of the scripts and the descriptions putting them into an array for each section its in
    while read -r line; do 
        IFS="," read -ra parsedLine <<< "$line"

        if [[ ${parsedLine[2],,} == "general" ]]; then
            generalLocation+=("${parsedLine[1]}")
            generalName+=("${parsedLine[0]}")
            generalPending+=("false")
        elif [[ ${parsedLine[2],,} == "ecomm" ]]; then
            ecommLocation+=("${parsedLine[1]}")
            ecommName+=("${parsedLine[0]}")
            ecommPending+=("false")
        elif [[ ${parsedLine[2],,} == "splunk" ]]; then
            splunkLocation+=("${parsedLine[1]}")
            splunkName+=("${parsedLine[0]}")
            splunkPending+=("false")
        elif [[ ${parsedLine[2],,} == "injects" ]]; then
            injectsLocation+=("${parsedLine[1]}")
            injectsName+=("${parsedLine[0]}")
            injectsPending+=("false")
        elif [[ ${parsedLine[2],,} == "web" ]]; then
            webserverLocation+=("${parsedLine[1]}")
            webserverName+=("${parsedLine[0]}")
            webserverPending+=("false")
        elif [[ ${parsedLine[2],,} == "email" ]]; then
            emailLocation+=("${parsedLine[1]}")
            emailName+=("${parsedLine[0]}")
            emailPending+=("false")
        fi
    done < "/tmp/Scripts.txt" # Change to /tmp/Scripts.txt

    
    # Now that we have all the scripts in their respective arrays we can display them to the user
    
    # Hold a variable for the current page
    page=1
    # Hold a variable for the current section
    sectionSelect=1
    # Hold a variable for the current selection
    selection=1

    clear

    # Main Loop
    drawStars
    # drawLogo

    while true; do
        # Draw the first page
        drawInstallPage $page $sectionSelect $selection
        if [[ $page == 1 ]]; then
            if [[ $sectionSelect == 1 ]]; then
                numberCommands=$((${#generalName[@]}))
            elif [[ $sectionSelect == 2 ]]; then
                numberCommands=$((${#ecommName[@]}))
            elif [[ $sectionSelect == 3 ]]; then
                numberCommands=$((${#splunkName[@]}))
            fi
        elif [[ $page == 2 ]]; then
            numberCommands=$((${#injectsName[@]} + 2))
        fi

        

        # Get the user input
        tput cup $(( $(tput lines) - 2 )) 0
        read -rsn1 -d'' key
        case $REPLY in
            "A") # Up arrow key
                #selection=$(( (selection - 2 + $numCommands + 0) % (${#commands[@]} + 2) + 0 ))
                selection=$(( (selection - 2 + $numberCommands + 0) % $numberCommands + 1 ))
                ;;
            "B") # Down arrow key
                selection=$(( selection % $numberCommands + 1 ))
                ;;
            "C") # Right arrow key
                # If the user reaches the end of the page, go to the next page
                if [[ $sectionSelect == 3 ]]; then
                    if [[ $page == 1 ]]; then
                        page=2
                    else
                        page=1
                    fi
                    clear
                    drawStars
                    sectionSelect=1
                else
                    sectionSelect=$(( sectionSelect + 1 ))
                fi
                
                ;;
            "D") # Left arrow key
                # If the user reaches the beginning of the page, go to the previous page
                if [[ $sectionSelect == 1 ]]; then
                    if [[ $page == 1 ]]; then
                        page=2
                    else
                        page=1
                    fi
                    clear
                    drawStars
                    sectionSelect=3
                else
                    sectionSelect=$(( sectionSelect - 1 ))
                fi
                ;;
            $'\x20')
                # Space key
                if [[ $page == 1 ]]; then
                    if [[ $sectionSelect == 1 ]]; then
                        if [[ ${generalPending[$(($selection - 1))]} == true ]]; then
                            generalPending[$(($selection - 1))]=false;
                        else
                            generalPending[$(($selection - 1))]=true;
                        fi
                    elif [[ $sectionSelect == 2 ]]; then
                        if [[ ${ecommPending[$(($selection - 1))]} == true ]]; then
                            ecommPending[$(($selection - 1))]=false;
                        else
                            ecommPending[$(($selection - 1))]=true;
                        fi
                    elif [[ $sectionSelect == 3 ]]; then
                        if [[ ${splunkPending[$(($selection - 1))]} == true ]]; then
                            splunkPending[$(($selection - 1))]=false;
                        else
                            splunkPending[$(($selection - 1))]=true;
                        fi
                    fi
                elif [[ $page == 2 ]]; then
                    if [[ $sectionSelect == 1 ]]; then
                        if [[ ${injectsPending[$(($selection - 1))]} == true ]]; then
                            injectsPending[$(($selection - 1))]=false;
                        else
                            injectsPending[$(($selection - 1))]=true;
                        fi
                    elif [[ $sectionSelect == 2 ]]; then
                        if [[ ${webserverPending[$(($selection - 1))]} == true ]]; then
                            webserverPending[$(($selection - 1))]=false;
                        else
                            webserverPending[$(($selection - 1))]=true;
                        fi
                    elif [[ $sectionSelect == 3 ]]; then
                        if [[ ${emailPending[$(($selection - 1))]} == true ]]; then
                            emailPending[$(($selection - 1))]=false;
                        else
                            emailPending[$(($selection - 1))]=true;
                        fi
                    fi
                fi
                ;;
            $'\x0a')
                # Enter key
                # Install the scripts that are marked
                # First gather all of the scripts that the user has selected

                installScripts=()

                # General Scripts
                for (( i=0; i<${#generalPending[@]}; i++ )); do
                    if [[ ${generalPending[$i]} == true ]]; then
                        installScripts+=("${generalLocation[$i]}")
                        scriptNames+=("${generalName[$i]}")
                    fi
                done

                # E-Comm Scripts
                for (( i=0; i<${#ecommPending[@]}; i++ )); do
                    if [[ ${ecommPending[$i]} == true ]]; then
                        installScripts+=("${ecommLocation[$i]}")
                        scriptNames+=("${ecommName[$i]}")
                    fi
                done

                # Splunk Scripts
                for (( i=0; i<${#splunkPending[@]}; i++ )); do
                    if [[ ${splunkPending[$i]} == true ]]; then
                        installScripts+=("${splunkLocation[$i]}")
                        scriptNames+=("${splunkName[$i]}")
                    fi
                done

                # Injects Scripts
                for (( i=0; i<${#injectsPending[@]}; i++ )); do
                    if [[ ${injectsPending[$i]} == true ]]; then
                        installScripts+=("${injectsLocation[$i]}")
                        scriptNames+=("${injectsName[$i]}")
                    fi
                done

                # Webserver Scripts
                for (( i=0; i<${#webserverPending[@]}; i++ )); do
                    if [[ ${webserverPending[$i]} == true ]]; then
                        installScripts+=("${webserverLocation[$i]}")
                        scriptNames+=("${webserverName[$i]}")
                    fi
                done

                # Email Scripts
                for (( i=0; i<${#emailPending[@]}; i++ )); do
                    if [[ ${emailPending[$i]} == true ]]; then
                        installScripts+=("${emailLocation[$i]}")
                        scriptNames+=("${emailName[$i]}")
                    fi
                done

                # Now that we have all the scripts that the user wants to install, we can install them
                # We will be installing them in the default location of /ccdc/scripts/linux/kronos

                # First we will check if the directory exists, if it does not we will create it
                if [[ ! -d $scriptLocation ]]; then
                    mkdir -p $scriptLocation
                fi

                echo "Downloading Scripts..."

                # Now we will loop through the array of scripts and download them
                for (( i=0; i<${#installScripts[@]}; i++ )); do
                    echo "Downloading ${scriptNames[$i]}"
                    # wget -q https://raw.githubusercontent.com/CCDC-Tools/Kronos/master/${installScripts[$i]} --directory-prefix "$scriptLocation" --show-progress 2>&1 || echo "Failed to install ${scriptNames[$i]}"
                    wget -q $githubURL/${installScripts[$i]} --directory-prefix "$scriptLocation" --show-progress || echo "Failed to install ${scriptNames[$i]}"
                done

                # Make all scripts in the directory executable
                chmod +x $scriptLocation*.sh

                sleep 1

                break
                ;;
            # Also check for the q key to quit
            "q")
                break
                ;;
        esac
    done
}






# Main runable
#Check if the user is root
if [[ $EUID -ne 0 ]]
then
  printf 'Must be run as root, exiting!\n'
  tput cnorm
  exit 1
fi

#Run the Main Screen
tput civis
loadingScreen
#sleep 1
getCommandList
selection=1
clear 
drawStars
drawLogo
while true; do
    while true; do
        drawSelection
        tput cup $(( $(tput lines) - 2 )) 0
        get_input

        case $key in
            "A" | "B")
                # User pressed arrow keys, update the menu
                ;;
            "")
                # User pressed enter, execute the selected option
                break
                ;;
        esac

    done

    # Execute the selected option
    tput cup $(( $(tput lines) - 3 )) 0
    if [[ $selection == $numCommands ]]; then
        tput cnorm
        exit 1
    # elif [ $selection == $(($numCommands - 1)) ] && [ $kronosNeedsInit == false ]; then
    elif [[ ${commands[$(($selection - 1))]} == "Initialize Kronos" ]]; then
        kronosInit
        getCommandList
        clear
        drawStars
        drawLogo
    elif [[ $selection == $(($numCommands - 1)) ]]; then
        scriptInstall && getCommandList && clear && drawStars && drawLogo 
    else
        clear
        tput cnorm
        # Run the script
        # Source and then run the main does some funky things
        bash $scriptLocation${commandSH[$(($selection - 1))]}
        sleep 1
        # Scripts do funky things
        tput civis
        clear
        drawStars
        drawLogo
    fi
done



# He he he 666