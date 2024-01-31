#!/bin/bash

getCommandName="InitBox" # The name of the command that will be used to start the script

echo "Hello World!"

# Ensure that screen is installed so we can run stuff in the background
if type yum; then
    yum install screen -y
elif type apt-get; then
    apt-get install screen -y
else
    echo "Could not install screen. Please install it manually."
    sleep 1
    return -1
fi

# Now we need to get all of the information from the user upfront
# So they are able to let it run in the background



