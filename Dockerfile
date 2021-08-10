ARG DEBIAN_VERSION=testing
# For some reason I can't track down, slirp networking just doesn't work with a buster container host! :(
#ARG DEBIAN_VERSION=stable
#ARG KERNEL_VERSION=5.2
ARG KERNEL_VERSION=5.10

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
# TODO: strip debugging out of the kernel?
# RUN strip linux
RUN mkdir /out && cp -f linux /out/linux
RUN cp .config /KERNEL.config


# BUILD STAGE: utility to print kernel config
# Usage:
#   docker build -t kernel_config_print --target config_print . && \
#   docker run -it --rm kernel_config_print > KERNEL.config
FROM debian:$DEBIAN_VERSION AS config_print
COPY --from=kernel_build /KERNEL.config /KERNEL.CONFIG
CMD ["cat", "/KERNEL.CONFIG"]


# BUILD STAGE: Main: build the image that will contain the usermode kernel, buildah, etc.
FROM debian:$DEBIAN_VERSION
RUN echo 'deb http://deb.debian.org/debian testing main contrib non-free' >> /etc/apt/sources.list
RUN \
  apt update && \
  apt install -y iproute2 wget slirp net-tools cgroupfs-mount psmisc rng-tools \
  apt-transport-https ca-certificates gnupg2 software-properties-common telnet
# TODO remote telnet and maybe a couple of other unecessary tools?

# Install buildah
# For older versions of debian (like buster), buildah is a testing package.
RUN \
  apt update && \
  apt install -y buildah

# Install kernel and scripts
COPY --from=kernel_build /out/linux /linux/linux
COPY entrypoint.sh entrypoint.sh
COPY init.sh init.sh
#COPY slirp-fullbolt-stable slirp-fullbolt-stable
COPY example.Dockerfile /Dockerfile

# Resource limits for the uml kernel
ENV MEM 2G
ENV DISK 5G

# It is recommended to override /umlshm with
# --tmpfs /umlshm:rw,nosuid,nodev,exec,size=8g
#ENV TMPDIR /umlshm
#VOLUME /umlshm
ENV TMPDIR /tmp

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "bash" ]
