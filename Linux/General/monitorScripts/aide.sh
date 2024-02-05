#!/bin/bash

echo -e "\n"
aide --check > /aide_log.txt
head /aide_log.txt
echo -e "\nUse 'vi /aide_log.txt' to get more detailed info"