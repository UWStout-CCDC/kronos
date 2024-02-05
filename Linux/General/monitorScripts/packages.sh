#!/bin/bash

echo -e "PACKAGE VERIFICATION:\n"
echo -e "---------------------\n"
if type dpkg
then
    dpkg -V
elif type rpm
then
    rpm -V
elif type apt
then
    apt list --installed
else
    echo "Unknown Package manager"
fi