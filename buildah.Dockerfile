FROM debian:testing
RUN apt update && apt install -y buildah ca-certificates
COPY example.Dockerfile Dockerfile
CMD buildah --isolation=chroot bud -t example . && buildah push example docker-archive:/example.image && ls -alh

# Run this with 
# docker build -f buildah.Dockerfile -t buildah . && docker run --privileged buildah
# ... next, use UML so that we don't have to use privileged!!
