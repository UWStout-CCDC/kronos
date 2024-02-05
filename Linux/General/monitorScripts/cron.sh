#!/bin/bash

echo -e "CRON JOBS:"
echo -e "Found Cronjobs for the following users:"
echo -e "---------------------------------------"
ls /var/spool/cron/crontabs
echo -e
echo -e "Cronjobs in cron.d:"
echo -e "-------------------"
ls /etc/cron.d/
sleep 5
clear