#!/bin/bash

# Environment variables:
# PODMAN_COMPOSE_URL - URL to compose file or bootstrap archive (.zip, .tar, .tar.gz)
# PODMAN_COMMAND - Direct podman command to execute

if [ ! -z "$DEBUG" ]; then
    set -x
fi

WORKSPACE="/workspace"
cd "$WORKSPACE" || exit 1

# Function to detect URL type and download
download_and_setup() {
    local url="$1"
    
    echo "Downloading from: $url"
    
    # Determine file type from URL
    if [[ "$url" =~ \.zip$ ]]; then
        echo "Detected ZIP archive"
        wget -O /tmp/bootstrap.zip "$url" || { echo "Download failed"; return 1; }
        unzip -o /tmp/bootstrap.zip -d "$WORKSPACE" || { echo "Extraction failed"; return 1; }
        rm /tmp/bootstrap.zip
        
    elif [[ "$url" =~ \.(tar\.gz|tgz)$ ]]; then
        echo "Detected TAR.GZ archive"
        wget -O /tmp/bootstrap.tar.gz "$url" || { echo "Download failed"; return 1; }
        tar -xzf /tmp/bootstrap.tar.gz -C "$WORKSPACE" || { echo "Extraction failed"; return 1; }
        rm /tmp/bootstrap.tar.gz
        
    elif [[ "$url" =~ \.tar$ ]]; then
        echo "Detected TAR archive"
        wget -O /tmp/bootstrap.tar "$url" || { echo "Download failed"; return 1; }
        tar -xf /tmp/bootstrap.tar -C "$WORKSPACE" || { echo "Extraction failed"; return 1; }
        rm /tmp/bootstrap.tar
        
    else
        # Assume it's a compose file
        echo "Detected compose file"
        wget -O "$WORKSPACE/docker-compose.yml" "$url" || { echo "Download failed"; return 1; }
    fi
    
    return 0
}

# Function to start compose project
start_compose() {
    local compose_file="${1:-docker-compose.yml}"
    
    if [ -f "$WORKSPACE/$compose_file" ]; then
        echo "Starting Podman Compose from $compose_file"
        cd "$WORKSPACE" || exit 1
        podman-compose -f "$compose_file" up -d
        return $?
    elif [ -f "$WORKSPACE/compose.yml" ]; then
        echo "Starting Podman Compose from compose.yml"
        cd "$WORKSPACE" || exit 1
        podman-compose -f compose.yml up -d
        return $?
    else
        echo "No compose file found"
        return 1
    fi
}

# Function to check if podman service is running
is_podman_service_running() {
    podman info >/dev/null 2>&1
    return $?
}

# Function to start and verify podman service
ensure_podman_service() {
    local max_retries=5
    local retry_count=0
    
    echo "Checking Podman service status..."
    
    # Check if already running
    if is_podman_service_running; then
        echo "Podman service is already running"
        return 0
    fi
    
    echo "Starting Podman system service..."
    podman system service --time=0 unix:///podman/podman.sock &
    local service_pid=$!
    
    # Wait and verify service is running
    while [ $retry_count -lt $max_retries ]; do
        sleep 2
        
        if is_podman_service_running; then
            echo "Podman service is running (PID: $service_pid)"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        echo "Waiting for Podman service to start... (attempt $retry_count/$max_retries)"
    done
    
    echo "ERROR: Failed to start Podman service after $max_retries attempts"
    return 1
}

# Main execution logic
echo "=== Podman GNS3 Container Starting ==="

# Ensure Podman service is running
if ! ensure_podman_service; then
    echo "Cannot continue without Podman service"
    exit 1
fi

# Handle PODMAN_COMPOSE_URL
if [ -n "$PODMAN_COMPOSE_URL" ]; then
    echo "Processing PODMAN_COMPOSE_URL: $PODMAN_COMPOSE_URL"
    
    if download_and_setup "$PODMAN_COMPOSE_URL"; then
        # Check if there's a Makefile with podman-init target
        if [ -f "$WORKSPACE/Makefile" ] && grep -q "podman-init:" "$WORKSPACE/Makefile"; then
            echo "Found Makefile with podman-init target, executing..."
            cd "$WORKSPACE" || exit 1
            make podman-init
        fi
        
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

# Check if podman-tui is available, otherwise use xterm
if command -v podman-tui >/dev/null 2>&1; then
    echo "Launching podman-tui..."
    xterm -e podman-tui
else
    echo "podman-tui not available, launching xterm..."
    xterm -e 'echo "Podman TUI is not installed. Please install podman-tui to use the interface."; bash'
fi