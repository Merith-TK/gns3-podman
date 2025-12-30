#!/bin/bash
# Environment variables:
# COMPOSE_FILE - URL to compose file or bootstrap archive (.tar, .tar.gz)
# PODMAN_COMMAND - Direct podman command to execute

[ -n "$DEBUG" ] && set -x

WORKSPACE="/workspace"
cd "$WORKSPACE" || exit 1

echo "=== Podman GNS3 Container Starting ==="

# Start Podman system service
echo "Starting Podman system service..."
if [ -S /podman/podman.sock ]; then
    echo "Service already running"
else
    podman system service --time=0 unix:///podman/podman.sock &
    for i in {1..5}; do
        sleep 2
        [ -S /podman/podman.sock ] && break
        echo "Waiting for socket... ($i/5)"
    done
    [ -S /podman/podman.sock ] || { echo "Failed to start service"; exit 1; }
    echo "Service started"
fi

# Download and setup compose file/archive
if [ -n "$COMPOSE_FILE" ]; then
    echo "Downloading: $COMPOSE_FILE"
    
    if [[ "$COMPOSE_FILE" =~ \.(tar\.gz|tgz)$ ]]; then
        wget -O - "$COMPOSE_FILE" | tar -xzf - -C "$WORKSPACE"
    elif [[ "$COMPOSE_FILE" =~ \.tar$ ]]; then
        wget -O - "$COMPOSE_FILE" | tar -xf - -C "$WORKSPACE"
    else
        wget -O "$WORKSPACE/docker-compose.yml" "$COMPOSE_FILE"
    fi
    
    # Run Makefile if exists
    [ -f Makefile ] && grep -q "podman-init:" Makefile && make podman-init
    
    # Start compose
    for compose in docker-compose.yml compose.yml; do
        if [ -f "$compose" ]; then
            echo "Starting: $compose"
            podman-compose -f "$compose" up
            break
        fi
    done
fi

# Execute direct command
[ -n "$PODMAN_COMMAND" ] && eval "$PODMAN_COMMAND" &

# Launch UI or shell
if [ -n "$DISPLAY" ]; then
    xterm -e "podman-tui 2>/dev/null || bash"
else
    echo "No GUI, starting shell..."
    bash
fi
