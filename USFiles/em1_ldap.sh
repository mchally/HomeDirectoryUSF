#!bin/sh
DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-auth-client nscd ldap-utils
cd /etc/
rm ldap.conf
wget http://amstel/ubuntu14/ldap_setup/ldap.conf
cd ldap/
rm ldap.conf
wget http://amstel/ubuntu14/ldap_setup/ldap/ldap.conf
auth-client-config -t nss -p lac_ldap
pam-auth-update --package ldap
/etc/init.d/nscd restart

apt-get install -y autofs autofs-ldap
cd /etc/default/
rm autofs
wget http://amstel/ubuntu14/ldap_setup/autofs
cd /etc/
rm nsswitch.conf
wget http://amstel/ubuntu14/ldap_setup/nsswitch.conf
/etc/init.d/autofs restart
 
cd /etc/network/
rm interfaces
printf '#The loopback network interface\nauto lo\nauto em1\niface lo inet loopback\niface em1 inet dhcp\n\n' | cat > interfaces

reboot
