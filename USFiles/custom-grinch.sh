#!bin/sh
#tk1 grinch script
#save the compiled cuda samples
mv NVIDIA_CUDA-6.5_Samples/ /opt/
cd /usr/src/
wget http://www.jarzebski.pl/files/jetsontk1/grinch-21.3.4/zImage
wget http://www.jarzebski.pl/files/jetsontk1/grinch-21.3.4/jetson-tk1-grinch-21.3.4-modules.tar.bz2
wget http://www.jarzebski.pl/files/jetsontk1/grinch-21.3.4/jetson-tk1-grinch-21.3.4-firmware.tar.bz2
tar -C /lib/modules -vxjf jetson-tk1-grinch-21.3.4-modules.tar.bz2
tar -C /lib -vxjf jetson-tk1-grinch-21.3.4-firmware.tar.bz2
cp zImage /boot/zImage
reboot
