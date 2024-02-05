#!/bin/bash

md5sum /etc/passwd /etc/group /etc/profile md5sum /etc/sudoers /etc/hosts /etc/ssh/ssh_config /etc/ssh/sshd_config > temp3
ls -a /etc/ /usr/ /sys/ /home/ /bin/ /etc/ssh/ >> temp3
fileChanges=$(diff temp2 temp3)
if [[ ! -z "$fileChanges" ]];then
  	echo CHANGE TRACKER:
	echo -e "\n"
	echo "$fileChanges"
    sleep 5
    clear
fi