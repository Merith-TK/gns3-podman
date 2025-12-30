# 🚀 GNS3 Podman VNC Appliance

> **Base Image**: `git.merith.xyz/gns3/base-vnc:latest`  
> Run Podman containers inside GNS3 with VNC access and automatic bootstrap

---

## 🔧 Quick Start

**Build & Push**:
```bash
docker build -t git.merith.xyz/gns3/podman:latest .
docker push git.merith.xyz/gns3/podman:latest
```

**GNS3 Setup**: Create Docker VM template with image `git.merith.xyz/gns3/podman:latest`

---

## 📋 Environment Variables

Configure via GNS3 template settings:

| Variable | Description | Example |
|----------|-------------|---------|
| `COMPOSE_FILE` | URL to compose file or `.tar`/`.tar.gz` archive | `https://example.com/app.tar.gz` |
| `PODMAN_COMMAND` | Direct podman command to execute | `run -d nginx:alpine` |
| `DEBUG` | Enable verbose output | `true` |

---

## 📦 Bootstrap Archives

Archives (`.tar` or `.tar.gz`) can contain:
- `docker-compose.yml` or `compose.yml` (required)
- Configuration files, scripts, etc.
- **`Makefile`** with `podman-init:` target (optional - runs before compose)

**Example structure**:
```
project.tar.gz
├── docker-compose.yml    # Required: Compose configuration
├── .env                  # Optional: Environment variables
├── config/               # Optional: Configuration files
│   └── app.conf
└── Makefile              # Optional: podman-init target auto-runs
```

---

## 🛠️ Features

- Automatic Podman service startup
- Bootstrap from URL (compose file or archive)
- Makefile `podman-init` support for pre-setup tasks
- VNC access with `podman-tui` interface
- Headless mode for non-GUI environments

---

## 🎯 Usage

1. Set `COMPOSE_FILE` or `PODMAN_COMMAND` in GNS3 template
2. Launch instance in GNS3
3. Connect via VNC to access `podman-tui`
4. Or SSH/console for headless access
