# use the base VNC image
FROM git.merith.xyz/gns3/base-vnc:latest
## START setting your image here

# Install Podman and required tools
RUN apk add --no-cache \
    podman \
    podman-compose \
    podman-tui \
    fuse-overlayfs \
    wget \
    curl \
    unzip \
    tar \
    gzip \
    make

# Configure Podman for running inside a container
RUN mkdir -p /etc/containers

# Configure storage to use vfs driver (compatible with nested containers)
RUN printf '[storage]\n\ndriver = "vfs"\n' > /etc/containers/storage.conf

# Configure containers.conf for cgroups v2 and disable resource limits
RUN printf '[engine]\n\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\n\n[engine.runtimes]\n' > /etc/containers/containers.conf

# Create workspace directory for podman projects
RUN mkdir -p /workspace

## STOP setting up your image here
# DO NOT REMOVE AND DO NOT ADD AN "ENTRYPOINT" COMMAND
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh