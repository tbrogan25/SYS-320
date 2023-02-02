#!/bin/bash

# Storyline: Script to create a WireGuard server


#Create a private key
p="$(wg genkey)"

#Create a public key
pub="$(echo ${p} | wg pubkey)"

#Set the addresses

address="192.168.8.0/24"

#Set Server IP addresses
ServerAddress="192.168.8.1"

#Set the listen port
lport="4282"

#Create the format for the client configuration options
peerInfo="# ${address} 198.199.97.163:4282  ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"

if [ -e /etc/wireguard/wg0.conf ]
then
  echo 'wg0.conf already exists. Do you want to overwrite it? (y/n)'
  read user_response
  if [ $user_response == 'y' ]
  then
    echo "
${peerInfo}
[Interface]
Address = ${ServerAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${p}
    " > /etc/wireguard/wg0.conf
    cat /etc/wireguard/wg0.conf
  else
    return
  fi
else
  echo "
  ${peerInfo}
  [Interface]
  Address = ${ServerAddress}
  #PostUp = /etc/wireguard/wg-up.bash
  #PostDown = /etc/wireguard/wg-down.bash
  ListenPort = ${lport}
  PrivateKey = ${p}
  " > /etc/wireguard/wg0.conf
fi
