#!/bin/bash

# Goal: Parse Apache log file and create firewall drop rules for Windows and Linux

# Check if log file exists

echo -n "Please enter an Apache log file."
echo ""
read tFile
if [[ ! -f ${tFile} ]]
then
	echo "File doesn't exist."
	exit 1
fi

# Looking for malicious web scanners within log file and adding their IPs to a file

sed -e "s/\[//g" -e "s/\"//g" ${tFile} | \
egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | \
while read -r line ; do
	awk ' { print $1 >> ".badIPs.txt" } '
done

# Adding scanner IP addresses into firewall drop rules

for eachIP in $( uniq .badIPs.txt)
do
	echo "iptables -A INPUT -s ${eachIP} -j DROP" >> badIPs.iptables
	echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachIP}\" dir=in action=block remoteip=${eachIP}" >> badIPs.ps1
done
