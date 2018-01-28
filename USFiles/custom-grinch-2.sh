#!bin/sh
#custom-grinch pt 2
wget http://www.jarzebski.pl/files/jetsontk1/grinch-21.3.4/jetson-tk1-grinch-21.3.4-source.tar.bz2
tar -C /usr/src -vxjf jetson-tk1-grinch-21.3.4-source.tar.bz2
#TODO: re-write /etc/hosts /etc/hostname
apt-get install salt-minion
#TODO: set /etc/salt/minion master: amstel
DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-auth-client nscd ldap-utils
auth-client-config -t nss -p lac_ldap
#TODO: manually change pam stuff for now
cd /etc/
rm ldap.conf
wget http://amstel/ubuntu14/ldap_setup/ldap.conf
cd ldap
rm ldap.conf
wget http://amstel/ubuntu14/ldap_setup/ldap/ldap.conf

#TODO: check out how libnss-ldapd works with noninteractive
apt-get install libnss-ldapd
service nscd restart

apt-get install -y autofs autofs-ldap
cd /etc/default/
rm autofs
wget http://amstel/ubuntu14/ldap_setup/autofs
cd /etc/
rm nsswitch.conf
wget http://amstel/ubuntu14/ldap_setup/nsswitch.conf
service autofs restart

#mpi~valgrind
cd /opt/
wget http://amstel/ubuntu14/tk1/openmpi-1.10.2.tar.bz2
tar -jxvf openmpi-1.10.2.tar.bz2
cd openmpi-1.10.2
./configure
make all install
wget http://amstel/ubuntu14/tk1/valgrind-3.11.0.tar.bz2
tar -jxvf valgrind-3.11.0.tar.bz2
cd valgrind-3.11.0.tar.bz2
./configure
make all install

reboot
#add whatever else



