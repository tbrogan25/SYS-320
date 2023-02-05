#!/bin/bash

# Storyline: Create peer VPN configuration file

# What is peer's name
echo -n "What is the peer's name?"
read the_client

# Filename variable
pFile="${the_client}-wg0.conf"

echo "${pFile}"

# Check if the peer file exists

if [[ -f "${pFile}"  ]]
then

	# Prompt if we need to overwrite the file
	echo "The file ${pFile} exists."
	echo -n "Do you want to overwrite it? [y/N]"
	read to_overwrite

	if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" ]]
	then

		echo "Exit..."
		exit 0

	elif [[ "${to_overwrite}" == "y" ]]
	then

		echo "Creating the wireguard configuration file..."

	# If the admin didn't specify a y or N then error.
	else

		echo "Invalid value"
		exit 1

	fi
fi


# Generate key
p="$(wg genkey)"

# Generate a public key
clientPub="$(echo ${p} | wg pubkey)"

# Generate a preshared key
pre="$(wg genpsk)"

# Endpoint
end="$(head -1 /etc/wireguard/wg0.conf | awk ' { print $3 } ')"

# Server Public Key
pub="$(head -1 /etc/wireguard/wg0.conf | awk ' { print $4 } ')"

# DNS servers
dns="$(head -1 /etc/wireguard/wg0.conf | awk ' { print $5 } ')"

# MTU
mtu="$(head -1 /etc/wireguard/wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 /etc/wireguard/wg0.conf | awk ' { print $7 } ')"

# ListenPort
lport="$(shuf -n1 -i 40000-50000)"

# Default routes for VPN
routes="$(head -1 /etc/wireguard/wg0.conf | awk ' { print $8 } ')"

# Create the client configuration file

: '
[Interface]
Address = 192.168.8.1
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = 4282
PrivateKey = mCTF/MIiZJVPl1EwUsZqvzm5aGnC+juG4dPt66bfVWA=
'

echo "[Interface]
Address = 192.168.8.1/24
DNS = ${dns}
Listenport = ${lport}
MTU = ${mtu}
PrivateKey = ${p}

[Peer]
AllowedIPs = ${routes}
PersistenKeepAlive = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFile}

# add our peer configuration to the server config

echo "
${the_client} # begin
[Peer]
Publickey = ${clientPub}
PresharedKey = ${pre}
AllowedIPs = 0.0.0.0.0/0
${the_client} # end
"  | tee -a /etc/wireguard/wg0.conf

echo "
sudo wg addconf wg0 <(wg-quick strip wg0)
"










