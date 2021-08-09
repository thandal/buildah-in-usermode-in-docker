#ARG DEBIAN_VERSION=9.9
ARG DEBIAN_VERSION=testing
ARG KERNEL_VERSION=5.2

# BUILD STAGE: Kernel: build the usermode kernel!
FROM debian:$DEBIAN_VERSION as kernel_build
ARG KERNEL_VERSION
RUN \
  apt update && \
  apt install -y git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc wget flex bison libelf-dev
RUN \
  wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VERSION.tar.xz && \
  tar -xf linux-$KERNEL_VERSION.tar.xz && \
  rm linux-$KERNEL_VERSION.tar.xz
WORKDIR linux-$KERNEL_VERSION
COPY KERNEL.config .config
RUN make ARCH=um oldconfig && make ARCH=um prepare
RUN make ARCH=um -j `nproc`
RUN mkdir /out && cp -f linux /out/linux
RUN cp .config /KERNEL.config


# BUILD STAGE: utility to print kernel config
# Usage: docker build -t foo --target config_print . && docker run -it --rm foo > KERNEL.config
FROM debian:$DEBIAN_VERSION AS config_print
COPY --from=kernel_build /KERNEL.config /KERNEL.CONFIG
CMD ["cat", "/KERNEL.CONFIG"]


# BUILD STAGE: Main: build the image that will contain the usermode kernel, buildah, etc.
FROM debian:$DEBIAN_VERSION
RUN \
	apt update && \
	apt install -y iproute2 wget slirp net-tools cgroupfs-mount psmisc rng-tools \
	apt-transport-https ca-certificates gnupg2 software-properties-common

# Install buildah
# For older versions of debian (like buster), buildah is a testing package.
#RUN echo 'deb http://deb.debian.org/debian testing main contrib non-free' >> /etc/apt/sources.list
RUN \
	apt update && \
	apt install -y buildah

# Install kernel and scripts
COPY --from=kernel_build /out/linux /linux/linux
COPY entrypoint.sh entrypoint.sh
COPY init.sh init.sh
COPY example.Dockerfile /Dockerfile

# Resource limits for the uml kernel
ENV MEM 2G
ENV DISK 10G

# It is recommended to override /umlshm with
# --tmpfs /umlshm:rw,nosuid,nodev,exec,size=8g
ENV TMPDIR /umlshm
VOLUME /umlshm

# Disk image for /var/lib/container is created under this directory
VOLUME /persistent

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "bash" ]
