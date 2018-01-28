#!bin/sh
cd /opt/
unzip google_appengine_1.9.34.zip
cd /etc/
printf 'export PATH=$PATH:/opt/google_appengine' >> bash.bashrc
