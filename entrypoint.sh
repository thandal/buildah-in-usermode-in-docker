#!/bin/bash

echo "Container: $(lsb_release -ds)"
echo "UML Kernel: $(/linux/linux --version)"
echo "Buildah: $(buildah --version)"
echo "Configuration: MEM=$MEM DISK=$DISK"

# Create the ext4 volume image for /var/lib/containers
if [ ! -f /persistent/var_lib_containers.img ]; then
    echo "Formatting /persistent/var_lib_docker.img"
    dd if=/dev/zero of=/persistent/var_lib_containers.img bs=1 count=0 seek=${DISK} > /dev/null 2>&1
    mkfs.ext4 /persistent/var_lib_containers.img > /dev/null 2>&1
fi

/linux/linux rootfstype=hostfs rw eth0=slirp,,/usr/bin/slirp-fullbolt mem=$MEM init=/init.sh
