#!/bin/bash

# Finds all UID 0 accounts
echo "UID 0 accounts:"
getent passwd | grep '0:0' | cut -d':' -f1 > /ccdc/uid0.txt
cat /ccdc/uid0.txt

# Find all users w/ sudo privs
echo "----------------------"
echo "Users with sudo privs:"
grep -E '^[^#%@]*\b(ALL|(S|s)udoers)\b' /etc/sudoers > /ccdc/sudoers.txt
cat /ccdc/sudoers.txt

# SUID binaries
echo "----------------------"
echo "SUID binaries:"
find / -uid 0 -perm -4000 -print 2>/dev/null > /ccdc/suid.txt
cat /ccdc/suid.txt