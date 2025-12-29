# 🖥️ GNS3 VNC Appliance Template

> **Base Image**: `git.merith.xyz/gns3/base-vnc:latest`  
Create custom VNC appliances for GNS3 with automatic startup scripts.

---

## 🚀 Quick Start

1. **Clone the template**:
```bash
git clone https://git.merith.xyz/gns3/vnc-template.git
cd vnc-template
```

2. **Customize your appliance**:
```dockerfile
FROM git.merith.xyz/gns3/base-vnc:latest

## ADD YOUR CUSTOMIZATIONS HERE ##
RUN apk add --no-cache firefox-esr xterm

## END CUSTOMIZATION ##
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
```

3. **Configure startup** (`entrypoint.sh`):
```bash
#!/bin/bash
# Start your applications automatically:
firefox &  # Launch in background
xterm      # Keep terminal open
```

4. **Build and push**:
```bash
docker build -t your-registry/vnc-firefox:latest .
docker push your-registry/vnc-firefox:latest
```

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
