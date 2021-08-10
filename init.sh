#!/bin/bash
set -xu
# UML black magic to make things play nice with rootfstype=hostfs
mount -t proc proc /proc/
mount -t sysfs sys /sys/
# TODO remove /run?
mount -t tmpfs none /run
mkdir /dev/pts
mount -t devpts devpts /dev/pts
rm /dev/ptmx
ln -s /dev/pts/ptmx /dev/ptmx

rngd -r /dev/urandom

# Set up networking
ip link set dev lo up
ip link set dev eth0 up
route add default dev eth0
ifconfig eth0 10.0.2.15

# Alternative network setup...
# 10.0.2.2 is a special slirp host alias
#ifconfig eth0 10.0.2.15 up
#route add default gw 10.0.2.2

# Don't really need the ext4 volume, but if I just try using a tmpfs, then
# buildah croaks with errors related to overlayfs...
# TODO: clean up this workaround for some issue with overlayfs and buildah.
mkdir -p /var/lib/containers
mount -t ext4 /var_lib_containers.img /var/lib/containers/

/etc/init.d/cgroupfs-mount start

echo '==============='
buildah bud -t example .
buildah push example docker-archive:/example.image 
ls -alh /example.image
echo '==============='

# Halting is the way init likes to end.
/sbin/halt -f
