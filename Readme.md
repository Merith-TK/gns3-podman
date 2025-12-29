# � GNS3 Podman VNC Appliance

> **Base Image**: `git.merith.xyz/gns3/base-vnc:latest`  
Run Podman containers inside GNS3 with VNC access and automatic container management.

---

## 🚀 Quick Start

**Build the image**:
```bash
docker build -t git.merith.xyz/gns3/podman:latest .
docker push git.merith.xyz/gns3/podman:latest
```

---

## 🔧 Configuration Methods

Configure Podman containers using environment variables in GNS3:

### Method 1: Compose File URL
Point to a `docker-compose.yml` or `compose.yml` file:
```bash
PODMAN_COMPOSE_URL=https://example.com/docker-compose.yml
```

### Method 2: Bootstrap Archive
Point to a `.zip`, `.tar`, or `.tar.gz` containing:
- `docker-compose.yml` or `compose.yml`
- Any required configuration files
- Optional `Makefile` with `podman-init` target for setup

```bash
PODMAN_COMPOSE_URL=https://example.com/project.zip
```

If a `Makefile` with `podman-init:` target exists, it will be executed before starting compose.

### Method 3: Direct Podman Command
Execute a raw podman command:
```bash
PODMAN_COMMAND="podman run -d -p 8080:80 nginx:alpine"
```

---

## 🖥️ Usage

1. **GNS3 Setup**: Create Docker VM template with image `git.merith.xyz/gns3/podman:latest`
2. **Set Environment Variables**: Add `PODMAN_COMPOSE_URL` or `PODMAN_COMMAND` in template settings
3. **Start Instance**: Launch in GNS3
4. **Connect via VNC**: Access the instance through GNS3's VNC viewer
5. **Manage Containers**: Use `podman-tui` (TUI interface) or `xterm` for manual control

---

## 📦 Example Bootstrap Archive Structure

```
project.zip
├── docker-compose.yml    # Required: Compose configuration
├── .env                  # Optional: Environment variables
├── config/              # Optional: Configuration files
│   └── app.conf
└── Makefile             # Optional: Setup automation
```

**Example Makefile**:
```makefile
podman-init:
	@echo "Initializing project..."
	mkdir -p volumes/data
	chmod 777 volumes/data
	@echo "Setup complete"
```

---

## 🛠️ Included Tools

- **podman** - Container runtime
- **podman-compose** - Docker Compose compatibility
- **podman-tui** - Terminal UI for container management
- **wget/curl** - File downloading
- **unzip/tar/gzip** - Archive extraction
- **make** - Makefile automation

---

## 🔧 GNS3 Appliance Configuration

1. In GNS3, create new **Docker VM** template:
   - **General Settings**:
     - Name: `Your-Appliance-Name`
     - Docker image: `your-registry/vnc-firefox:latest`
   - **Network**:
     - `eth0` = `Management` (NAT)
     - Additional NICs as needed
   - **Console**:
     - Type: `VNC`
     - Port: `5900`

---

## 🧩 Key Components

| File             | Purpose                                                                 |
|------------------|-------------------------------------------------------------------------|
| `Dockerfile`     | Extends base image with your custom tools                               |
| `entrypoint.sh`  | **Auto-starts** when appliance boots (launch your apps/services here)  |
| `i3.config`      | (In base image) Auto-runs `/entrypoint.sh` on startup                  |
