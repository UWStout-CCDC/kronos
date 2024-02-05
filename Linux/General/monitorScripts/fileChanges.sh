#!/bin/bash

echo -e "FILE CHANGE TRACKER:\n"
echo -e "---------------------\n"
md5sum /etc/passwd /etc/group /etc/profile /etc/sudoers /etc/hosts /etc/ssh/ssh_config /etc/ssh/sshd_config > temp3
ls -a /etc/ /usr/ /sys/ /home/ /bin/ /etc/ssh/ >> temp3
fileChanges=$(diff temp2 temp3)
if [[ ! -z "$fileChanges" ]];then
  	echo -e "CHANGE TRACKER:"
	echo -e "\n"
	echo -e "$fileChanges"
    sleep 5
    clear
fi