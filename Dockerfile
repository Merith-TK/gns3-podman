# use the base VNC image
FROM git.merith.xyz/gns3/base-vnc:latest
## START setting your image here

# Install Podman and required tools
RUN apk add --no-cache \
    podman \
    podman-compose \
    podman-tui \
    wget \
    curl \
    unzip \
    tar \
    gzip \
    make

# Configure Podman for rootless operation (running as root, but setup for compatibility)
RUN mkdir -p /etc/containers

# Create workspace directory for podman projects
RUN mkdir -p /workspace

## STOP setting up your image here
# DO NOT REMOVE AND DO NOT ADD AN "ENTRYPOINT" COMMAND
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh