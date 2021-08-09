# Buildah in User-Mode Linux in Docker (BUMLD)

An image for running buildah inside a user-mode linux kernel inside a docker container.
This way it is possible to build docker images without forwarding the docker socket or using privileged flags.
Therefore this image can be used to build docker images with the gitlab-ci-multi-runner docker executor.

## How it works

It starts a user-mode linux kernel with buildah inside.
The network communication is bridged by slirp.

## Example

`docker run -it --rm bumld buildah --version`

For better performance, mount a tmpfs with exec access on `/umlshm`:

`docker run -it --rm --tmpfs /umlshm:rw,nosuid,nodev,exec,size=8g weberlars/diuid docker info`

To configure memory size and `/var/lib/docker` size:

`docker run -it --rm -e MEM=4G -e DISK=20G weberlars/diuid docker info`

To preserve `/var/lib/docker` disk:

`docker run -it --rm -v /somewhere:/persistent weberlars/diuid docker info`

