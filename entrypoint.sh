#!/bin/bash

echo "Container: $(lsb_release -ds)"
echo "UML Kernel: $(/linux/linux --version)"
echo "Buildah: $(buildah --version)"
echo "Configuration: MEM=$MEM DISK=$DISK"

# Create the ext4 volume image for UML to mount as /var/lib/containers
# TODO: clean up this workaround for some issue with overlayfs and buildah.
if [ ! -f /var_lib_containers.img ]; then
    echo "Formatting /var_lib_docker.img"
    dd if=/dev/zero of=/var_lib_containers.img bs=1 count=0 seek=${DISK} > /dev/null 2>&1
    mkfs.ext4 /var_lib_containers.img > /dev/null 2>&1
fi

/linux/linux rootfstype=hostfs rw eth0=slirp,,/usr/bin/slirp-fullbolt mem=$MEM init=/init.sh
