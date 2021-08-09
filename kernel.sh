#!/bin/bash
#exec /linux/linux rootfstype=hostfs rw eth0=slirp,,/usr/bin/slirp-fullbolt mem=$MEM init=/init.sh
exec /linux/linux rootfstype=hostfs rw eth0=slirp,,/slirp mem=$MEM init=/init.sh
#exec /linux/linux rootfstype=hostfs rw mem=$MEM init=/init.sh
