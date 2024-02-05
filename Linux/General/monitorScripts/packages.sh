#!/bin/bash

if type dpkg
then
    dpkg -V
elif type rpm
then
    rpm -V
else
    echo "Unknown Package manager"
fi