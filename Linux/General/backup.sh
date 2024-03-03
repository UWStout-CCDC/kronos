#!/bin/bash

echo "Starting Backups"

path=/ccdc/backups

mkdir 
cd /
folders="etc var root home sbin bin opt"
for dir in $folders; do
    tar czvfp $path/${dir}.tgz ${dir}
done
cp -p -r /var/www/ $path/wwwbckp
tar czvfp $(hostname).tgz backups

echo "Backup Complete"