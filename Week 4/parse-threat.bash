#!/bin/bash

# Storyline: Create multiple switches to form firewall block lists for different systems

# Create a firewall ruleset for different firewall types

while getopts 'eicwmdh' OPTION ; do

	case "$OPTION" in
		# Extract IPs from emergingthreats.net and create a firewall ruleset
		# Check for exisiting /tmp/emerging-drop.rules file before downloading from the Internet
		e) emerging=${OPTION}
			if [[ -f "/tmp/emerging-drop.rules" ]]
			then
				# Prompt if we need to overwrite the file
				echo "The file /tmp/emerging-drop.rules already exists."
				echo -n "Do you want to overwrite it? [y/N]"
				read to_overwrite

				if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n" ]]
				then
					echo "Exiting..."
					break
				elif [[ "${to_overwrite}" == "y" ]]
				then
					echo "Saving to /tmp/emerging-drop.rules file"
					wget https://rules.emergingthreats.net/blockrules/emerging-drop.rules -O /tmp/emerging-drop.rules
				else
					echo "Invalid value"
					exit 1
				fi
			else
				wget https://rules.emergingthreats.net/blockrules/emerging-drop.rules -O /tmp/emerging-drop.rules
			fi

			# Cut the specific IPs from the emerging-drop.rules file > badIPs.txt
			egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.rules | sort -u | tee badIPs.txt
		;;
		# Extract IPs from badIPs.txt and create a Linux firewall block list
		i) iptables=${OPTION}
			for eachIP in $(cat badIPs.txt)
			do
				echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a badIPs.iptables
			done
		;;
		# Extract IPs from badIPs.txt and create a Cisco firewall block list
		c) cisco=${OPTION}
			for eachIP in $(cat badIPs.txt)
			do
				echo "access-list 1 deny host ${eachIP}" | tee -a badIPs.cisco
			done
		;;
		# Extract IPs from badIPs.txt and create a Windows firewall block list
		w) windows=${OPTION}
			for eachIP in $(cat badIPs.txt)
			do
				echo "New-NetFirewallRule -RemoteAddress ${eachIP} -DisplayName 'Block Bad IP: ${eachIP}' -Direction inbound -Profile Any -Action Block" | tee -a badIPs.windows
			done
		;;
		# Extract IPs from badIPs.txt and create a Mac firewall block list
		m) mac=${OPTION}
			for eachIP in $(cat badIPs.txt)
			do
				echo "block drop from any to ${eachIP}" | tee -a badIPs.mac
			done
		;;
		# Extract domains from badDomains.cisco and create a domain block list
		# Storyline
			# 1. Pull file and search for only lines with "domain"
			# 2. Use the "cut" or "awk" commands to split each line based on a delimeter
			# 3. Put the cut domains in a file with the following format:
			# 3a. "match protocol http host 'domainname.com'"
			# 4. Begin the file with the line: "class-map match-any BAD_URLS"
		d) domain=${OPTION}
			wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/badDomains.cisco
			grep 'domain' /tmp/badDomains.cisco | awk -F, '{gsub(/"/,""); print $2}' >> badDomains.txt
			# domains = "$(grep 'domain' /tmp/badDomains.cisco | awk -F, '{gsub(/'/,""); print $2)"
			echo "class-map match-any BAD_URLS" > badDomains.cisco
			for line in $(cat badDomains.txt)
			do
				echo "match protocol http host $line" >> badDomains.cisco
			done
		;;
		h)

			echo ""
			echo "Usage: bash parse-threat.bash [-i][-c][-w][-m][-d]"

	esac
done
