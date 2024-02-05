#!/bin/bash
 
echo -e "\nCurrent Logins:\n"
echo -e "---------------\n"
w
echo -e "\nRecent Logins\n"
echo -e "-------------\n"
last
echo -e "\nFailed Logins\n"
echo -e "-------------\n"
cat /var/log/auth.log | grep "Failed password"