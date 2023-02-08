#!/bin/bash

# Storyline: Script to add and delete VPN peers

while getopts 'hdacu:' OPTION ; do

	case "$OPTION" in

		d) u_del=${OPTION}
		;;
		a) u_add=${OPTION}
		;;
		c) c_user=${OPTION}
		;;
		u) t_user=${OPTARG}
		;;
		h)

			echo ""
			echo "Usage: $(basename $0) [-a]|[-d]|[-c] -u username"
			echo ""
			exit 1

		;;


		*)

			echo "Invalid value."
			exit 1

		;;
	esac
done

# Check to see if the -a and -d are empty of if they are both specified throw an error
if [[ (${u_del} == "" && ${u_add} == "" && ${c_user} == "") || (${u_del} != "" && ${u_add} != "" && ${c_user} != "") ]]
then

	echo "Please specify -a or -d or -c and the -u and username".

fi

# Check to ensure -u is specified
if [[ (${u_del} != "" || ${u_add} != "") && ${t_user} == "" ]]
then

	echo "Please specify a user (-u)!"
	echo "Usage: $(basename $0) [-a][-d][-c] -u username"
	exit 1

fi

# Delete a user
if [[ ${u_del} ]]
then

	echo "Deleting user..."
	sed -i "/# ${t_user} begin/,/# ${t_user} end/d" wg0.conf

fi

# Add a user
if [[ ${u_add} ]]
then

	echo "Create the User..."
	bash peer.bash ${t_user}

fi

# Check the existence of a user
if [[ ${c_user} ]]
then

	echo "Checking for user..."
	if cat wg0.conf | grep -i -q -w ${t_user}
	then

		echo "That user exists"

	else 

		echo "That user does not exist"

	fi 

fi













