#!/bin/bash

# Environment variables:
# COMPOSE_FILE - URL to compose file or bootstrap archive (.zip, .tar, .tar.gz)
# PODMAN_COMMAND - Direct podman command to execute

[ -n "$DEBUG" ] && set -x

WORKSPACE="/workspace"
cd "$WORKSPACE" || exit 1

# Function to download and setup from URL
download_and_setup() {
    local url="$1"
    
    echo "Downloading from: $url"
    
    # Parse file type from URL
    if [[ "$url" =~ \.(tar\.gz|tgz)$ ]]; then
        echo "Detected: TAR.GZ archive"
        wget -O - "$url" | tar -xzf - -C "$WORKSPACE" || { echo "Failed"; return 1; }
    elif [[ "$url" =~ \.tar$ ]]; then
        echo "Detected: TAR archive"
        wget -O - "$url" | tar -xf - -C "$WORKSPACE" || { echo "Failed"; return 1; }
    else
        echo "Detected: Compose file"
        wget -O "$WORKSPACE/docker-compose.yml" "$url" || { echo "Failed"; return 1; }
    fi
    
    # Check for Makefile with podman-init target
    if [ -f "$WORKSPACE/Makefile" ] && grep -q "podman-init:" "$WORKSPACE/Makefile"; then
        echo "Running Makefile podman-init..."
        cd "$WORKSPACE" && make podman-init
    fi
    
    return 0
}


# Function to start compose project
start_compose() {
    for compose in docker-compose.yml compose.yml; do
        if [ -f "$WORKSPACE/$compose" ]; then
            echo "Starting: $compose"
            podman-compose -f "$compose" up -d
            return $?
        fi
    done
    echo "No compose file found"
    return 1
}

# Function to start and verify podman service
ensure_podman_service() {
    local max_retries=5
    local retry_count=0
    
    echo "Checking Podman service status..."
    
    # Check if already running
    if [ -S /podman/podman.sock ]; then
        echo "Podman service is already running"
        return 0
    fi
    
    echo "Starting Podman system service..."
    podman system service --time=0 unix:///podman/podman.sock &
    local service_pid=$!
    echo "Started service with PID: $service_pid"
    
    # Wait and verify service is running
    while [ $retry_count -lt $max_retries ]; do
        sleep 2
        
        if [ -S /podman/podman.sock ]; then
            echo "Podman service socket is active: /podman/podman.sock"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        echo "Waiting for Podman service socket... (attempt $retry_count/$max_retries)"
    done
    
    echo "ERROR: Failed to start Podman service after $max_retries attempts"
    echo "Check: ls -la /podman/"
    ls -la /podman/ 2>&1 || echo "Directory does not exist"
    return 1
}

# Main execution logic
echo "=== Podman GNS3 Container Starting ==="

# Ensure Podman service is running
if ! ensure_podman_service; then
    echo "Cannot continue without Podman service"
    exit 1
fi

# Handle COMPOSE_FILE
if [ -n "$COMPOSE_FILE" ]; then
    echo "Processing COMPOSE_FILE: $COMPOSE_FILE"
    
    if download_and_setup "$COMPOSE_FILE"; then
        # Start compose
        start_compose
    else
        echo "Failed to download and setup from URL"
    fi
fi

# Handle direct PODMAN_COMMAND
if [ -n "$PODMAN_COMMAND" ]; then
    echo "Executing PODMAN_COMMAND: $PODMAN_COMMAND"
    cd "$WORKSPACE" || exit 1
    eval "$PODMAN_COMMAND" &
fi

# Launch GUI or shell
if [ -n "$DISPLAY" ]; then
    xterm -e "podman-tui 2>/dev/null || bash"
else
    echo "No GUI detected, dropping to shell..."
    bash
fi
