#!/bin/bash

echo -e "\n"
netstat -n -A inet | grep ESTABLISHED | grep -vP ":(80|443|53|123)"