#!/bin/bash

echo -e "\nUsers Able to Login:\n"
echo -e "---------------------\n"
cat /etc/passwd | grep -v /sbin/nologin | grep -v /bin/false | awk -F: '{print $1, $7}'