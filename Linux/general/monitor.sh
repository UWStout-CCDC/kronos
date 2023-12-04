#!/bin/bash
getCommandName() {
    echo "System Monitor"
}

#TODO:
#-Create monitor script with interactive panels that dynamically update
# Need to create a panel at the bottom/top/side of terminal that has options for what to monitor
# Each panel will update itself when selected and continously update while open on an interval
# Each panel will also make use of less to allow user to navigate the output
# Take inspiration from monitor.sh but rewrite it