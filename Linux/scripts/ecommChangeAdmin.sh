#!/bin/bash
getCommandName="Change Admin Pass"

# This script is used to change the admin password for the ecomm application, by updating the database.

# Check if the user is root
if [ $(id -u) -ne 0 ]; then
    echo "You must be root to run this script."
    exit 1
fi

# Get information from the user, sql user and password
read -p "Enter the SQL username: " SQLUSER
read -s -p "Enter the SQL password: " SQLPASSWORD
clear

# Check if they want to 1 break authentication, or 2 change the admin password
echo "What would you like to do?"
echo "1. Break authentication"
echo "2. Change the admin password"
read -p "Enter the number of your choice: " CHOICE
clear

# If they want to break authentication, then do so
if [ $CHOICE -eq 1 ]; then
    echo "Breaking authentication..."
    mysql -u $SQLUSER -p$SQLPASSWORD -D prestashop <<EOF
UPDATE employee SET passwd='%%%%%%%' WHERE id_employee='1';
EOF

    echo "Authentication broken."
    exit 0
elif [ $CHOICE -eq 2 ]; then
    echo "Changing the admin password..."
    read -s -p "Enter the new password for the admin user: " NEW
    clear

    # we need to hash the password with the same algorithm as prestashop which uses php password_hash
    NEW=$(php -r "echo password_hash('$NEW', PASSWORD_DEFAULT);")

    # Update the database
    echo "Updating the database..."
    mysql -u $SQLUSER -p$SQLPASSWORD -D prestashop <<EOF
UPDATE employee SET passwd=$NEW WHERE id_employee='1';
EOF
    echo "Password updated."
    exit 0
else
    echo "Invalid choice."
    exit 1
fi