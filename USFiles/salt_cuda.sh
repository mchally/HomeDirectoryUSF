#!bin/sh
#may have to run and reboot first. test whether or not after a fresh reboot with no logins and should work first try.
cd /tmp
rm .X0-lock
cd /opt/
./cuda_exp_script
export PATH=/usr/local/cuda-6.5/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-6.5/lib64:$LD_LIBRARY_PATH
reboot

