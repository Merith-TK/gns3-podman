# use the base VNC image
FROM git.merith.xyz/gns3/base-vnc:latest
## START setting your image here

# Install Podman and required tools
RUN apk add --no-cache \
    podman \
    podman-compose \
    podman-tui \
    fuse-overlayfs \
    iptables \
    ip6tables \
    wget \
    curl \
    unzip \
    tar \
    gzip \
    make \
    nano

# Configure Podman for running inside a container
RUN mkdir -p /etc/containers /var/lib/containers/storage

# Configure storage to use vfs driver with explicit paths
RUN printf '[storage]\ndriver = "vfs"\nrunroot = "/var/run/containers/storage"\ngraphroot = "/var/lib/containers/storage"\n\n[storage.options]\nmount_program = "/usr/bin/fuse-overlayfs"\n' > /etc/containers/storage.conf

# Configure containers.conf
RUN printf '[engine]\ncgroup_manager = "cgroupfs"\nevents_logger = "file"\nruntime = "crun"\n' > /etc/containers/containers.conf

# Create necessary directories
RUN mkdir -p /workspace /podman /var/run/containers/storage /var/lib/containers/storage

# Set environment variables for podman
ENV PODMAN_IGNORE_CGROUPSV1_WARNING=1

VOLUME [ "/workspace", "/etc/containers", "/var/lib/containers" ]

## STOP setting up your image here
# DO NOT REMOVE AND DO NOT ADD AN "ENTRYPOINT" COMMAND
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh