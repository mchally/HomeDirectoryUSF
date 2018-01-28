#!/bin/sh

#Fun time key tricks
RSA1_KEY=ssh_host_key
RSA_KEY=ssh_host_rsa_key
DSA_KEY=ssh_host_dsa_key
#make sure correct interface: eth0 or em1
#working on solution.
#CHECK='ifconfig eth0'
#ERROR='error'
#if "${CHECK#*$ERROR}" != "$CHECK"
#then IP = what's below
#else IP = ifconfig em1....
IP=`ifconfig  eth0 | grep inet | awk '{ print $2 }' | awk -F: '{ print $2 }'`
NODE=`host $IP | awk '{ print $5 }' | awk -F. '{ print $1 }'`

cd /opt/
wget -r -l1 http://amstel/ubuntu14/keys/

cp /opt/amstel/ubuntu14/keys/$RSA1_KEY.$NODE /etc/ssh/$RSA1_KEY
cp /opt/amstel/ubuntu14/keys/$RSA1_KEY.$NODE.pub /etc/ssh/$RSA1_KEY.pub
cp /opt/amstel/ubuntu14/keys/$RSA_KEY.$NODE /etc/ssh/$RSA_KEY
cp /opt/amstel/ubuntu14/keys/$RSA_KEY.$NODE.pub /etc/ssh/$RSA_KEY.pub
cp /opt/amstel/ubuntu14/keys/$DSA_KEY.$NODE /etc/ssh/$DSA_KEY
cp /opt/amstel/ubuntu14/keys/$DSA_KEY.$NODE.pub /etc/ssh/$DSA_KEY.pub

cp /opt/amstel/ubuntu14/keys/ssh_known_hosts2 /etc/ssh/
cp -f /opt/amstel/ubuntu14/keys/ssh_config /etc/ssh/

rm -rf /opt/amstel

cd /root
mkdir .ssh/
cd .ssh/
wget http://amstel/ubuntu14/ssh/authorized_keys2
wget http://amstel/ubuntu14/ssh/known_hosts

