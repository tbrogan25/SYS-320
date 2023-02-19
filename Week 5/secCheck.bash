#!/bin/bash

# Storyline: Script to perform local security checks

function checks() {

	if [[ $2 != $3 ]]
	then

		echo -e "\e[1;31mThe $1 is not compliant. \nThe current policy should be: $2. \nThe current value is: $3.\nRemediation:\n$4\e[0m\n"

	else

		echo -e "\e[1;32mThe $1 is compliant. Current value is: $3.\e[0m\n"

	fi

}


# Check the password max days policy

pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' { print $2 } ')

# Check for password max

checks "Password Max Days" "365" "${pmax}" "Set the PASS_MAX_DAYS parameter to 365 in /etc/login.defs"

# Check the pass min days between changes

pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' { print $2 } ')

checks "Password Min Days" "14" "${pmin}" "Set the PASS_MIN_DAYS parameter to 14 in /etc/login.defs"

# Check the pass warn age

pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' { print $2 } ')

checks "Password Warn Age" "7" "${pwarn}" "Set the PASS_WARN_AGE parameter to 7 in /etc/login.defs"

# Check the SSH UsePam Configuration

chkSSHPAM=$(egrep -i "UsePAM" /etc/ssh/ssh_config | awk ' { print $2 } ' )
checks "SSH UsePAM" "yes" "${chkSSHPAM}" ""

# Check permissions on users' home directory

#echo ""
for eachDir in $(ls -l /home | egrep '^d' | awk ' { print $3 } ' )
do

	chDir=$(ls -ld /home/${eachDir} | awk ' { print $1 } ' )
	checks "Home directory ${eachDir}" "drwx------" "${chDir}" ""

done

# Check if IP forwarding is disabled

chkIPforward=$(egrep -i 'net\.ipv4\.ip_forward' /etc/sysctl.conf | cut -d '=' -f 2-)
checks "IP Forwarding" "0" "${chkIPforward}" "Edit /etc/sysctl.conf and set 'net.ipv4.ip_forward = 0'. Then run:\nsysctl -w net.ipv4.ip forward=0\nsysctl -w net.ipv4.route.flush=1"

# Check if ICMP redirects are accepted or not

chkICMPredirect=$(grep "net\.ipv4\.conf\.all\.accept_redirects" /etc/sysctl.conf | awk ' { print $3 } ')
checks "ICMP Redirects" "0" "${chkICMPredirect}" "Edit /etc/sysctl.conf and set 'net.ipv4.conf.all.accept redirects = 0'. Then run:\nsysctl -w net.ipv4.conf.all.accept redirects=0\nsysctl -w net.ipv4.conf.default.accept redirects=0\nsysctl -w net.ipv4.route.flush=1"

# Check if permissions on /etc/crontab are configured

chkcrontab=$(stat /etc/crontab | head -4 | tail -1)
checks "/etc/crontab Permissions" "\nAccess: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${chkcrontab}" "Run:\nchown root:root /etc/crontab\nchmod og-rwx /etc/crontab"

# Check if permissions on /etc/cron.hourly are configured

chkcronhourly=$(stat /etc/cron.hourly | head -4 | tail -1 )
checks "/etc/cron.hourly Permissions" "\nAccess: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${chkcronhourly}" "Run:\nchown root:root /etc/cron.hourly\nchmod og-rwx /etc/cron.hourly"

# Check if permissions on /etc/cron.daily are configured

chkcrondaily=$(stat /etc/cron.daily | head -4 | tail -1)
checks "/etc/cron.daily Permissions" "\nAccess: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${chkcrondaily}" "Run:\nchown root:root /etc/cron.daily\nchmod og-rwx /etc/cron.daily"

# Check if permissions on /etc/cron.weekly are configured

chkcronweekly=$(stat /etc/cron.weekly | head -4 | tail -1)
checks "/etc/cron.weekly Permissions" "\nAccess: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${chkcronweekly}" "Run:\nchown root:root /etc/cron.weekly\nchmod og-rwx /etc/cron.weekly"

# Check if permissions on /etc/cron.monthly are configured

chkcronmonthly=$(stat /etc/cron.monthly | head -4 | tail -1)
checks "/etc/cron.monthly Permissions" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${chkcronmonthly}" "Run:\nchown root:root /etc/cron.monthly\nchmod og-rwx /etc/cron.monthly"

# Check if permissions on /etc/passwd are configured

chketcpasswd=$(stat /etc/passwd | head -4 | tail -1)
checks "/etc/passwd Permissions" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chketcpasswd}" "Run:\nchown root:root /etc/passwd\nchmod 644 /etc/passwd"

# Check if permissions on /etc/shadow are configured

chketcshadow=$(stat /etc/shadow | head -4 | tail -1)
checks "/etc/shadow Permissions" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chketcshadow}" "Run:\nchown root:shadow /etc/shadow\nchmod o-rwx,g-wx /etc/shadow"

# Check if permissions on /etc/group are configured

chketcgroup=$(stat /etc/group | head -4 | tail -1)
checks "/etc/group Permissions" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chketcgroup}" "Run:\nchown root:root /etc/group\nchmod 644 /etc/group"

# Check if permissions on /etc/gshadow are configured

chketcgshadow=$(stat /etc/gshadow | head -4 | tail -1)
checks "/etc/gshadow Permissions" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chketcgshadow}" "Run:\nchown root:shadow /etc/gshadow\nchmod o-rwx,g-rw /etc/gshadow"

# Check if permissions on /etc/passwd- are configured

chketcpasswd2=$(stat /etc/passwd- | head -4 | tail -1)
checks "/etc/passwd- Permissions" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chketcpasswd2}" "Run:\nchown root:root /etc/passwd-\nchmod u-x,go-wx /etc/passwd2"

# Check if permissions on /etc/shadow- are configured

chketcshadow2=$(stat /etc/shadow- | head -4 | tail -1)
checks "/etc/shadow- Permissions" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chketcshadow2}" "Run:\nchown root:root /etc/shadow-\nchmod u-x,go-wx /etc/shadow-"

# Check if permissions on /etc/group- are configured

chketcgroup2=$(stat /etc/group- | head -4 | tail -1)
checks "/etc/group- Permissions" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${chketcgroup2}" "Run:\nchown root:root /etc/group-\nchmod u-x,go-wx /etc/group-"

# Check if permissions on /etc/gshadow- are configured

chketcgshadow2=$(stat /etc/gshadow- | head -4 | tail -1)
checks "/etc/gshadow- Permissions" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${chketcgshadow2}" "Run:\nchown root:shadow /etc/gshadow-\nchmod o-rwx,g-rw /etc/gshadow-"

# Check that no legacy '+' entries exist in /etc/passwd

chketcpasswdlegacy=$(grep '^\+:' /etc/passwd)
checks "/etc/passwd Legacy Entries" "" "${chketcpasswdlegacy}" "Remove any legacy '+' entries if they exist" 

# Check that no legacy '+' entries exist in /etc/shadow

chketcshadowlegacy=$(grep '^\+:' /etc/shadow)
checks "/etc/shadow Legacy Entries" "" "${chketcshadowlegacy}" "Remove any legacy '+' entries if they exist" 

# Check that no legacy '+' entries exist in /etc/group

chketcgrouplegacy=$(grep '^\+:' /etc/group)
checks "/etc/group Legacy Entries" "" "${chketcgrouplegacy}" "Remove any legacy '+' entries if they exist" 

# Check that root is the only UID 0 account

chkRoot=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 }')
checks "UID 0" "root" "${chkRoot}" "Remove any users other than root with UID 0"
