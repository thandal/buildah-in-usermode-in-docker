#!/bin/bash
set -xu
mount -t proc proc /proc/
mount -t sysfs sys /sys/
mount -t tmpfs none /run
mkdir /dev/pts
mount -t devpts devpts /dev/pts
rm /dev/ptmx
ln -s /dev/pts/ptmx /dev/ptmx
rngd -r /dev/urandom

mkdir -p /var/lib/containers/
mount -t ext4 /persistent/var_lib_containers.img /var/lib/containers/

# Set up networking
ip link set dev lo up
ip link set dev eth0 up
route add default dev eth0
ifconfig eth0 10.0.2.15

/etc/init.d/cgroupfs-mount start

echo '==============='
buildah bud -t example .
buildah push example docker-archive:/example.image 
ls -alh
echo '==============='

# Halting is the way init likes to end.
/sbin/halt -f
