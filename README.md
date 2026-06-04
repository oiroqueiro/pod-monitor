> [!NOTE]
> This project and all its documentation have been automatically and completely developed by **Gemini (Antigravity)** under the supervision and management of **Oscar Iglesias Roqueiro** (@oiroqueiro).

# 📊 Podman Monitor: Hardened Observability Stack

A high-performance, efficient, and **secure-by-design** system monitoring and log aggregation stack. This project packages **Node Exporter**, **Podman Exporter**, and **Prometheus Promtail** into a single Pod using rootless/system-wide **Podman** and **Quadlets**, integrated natively with Linux `systemd`.

This stack is designed to expose metrics endpoints securely for scraping by a central Prometheus server, and to collect and forward system and container logs to a central Loki instance over a private network interface (e.g. Netbird VPN).

---

## 🏗️ Architecture & Component Stack

The stack consolidates three core monitoring services into a single systemd-managed Pod:

| Component | Upstream Image | Hardened Base Image | Purpose & Scope |
| :--- | :--- | :--- | :--- |
| **Node Exporter** | `quay.io/prometheus/node-exporter` | `docker.io/library/alpine` (Minimal) | Captures OS-level metrics (CPU, RAM, Disk, IO). |
| **Podman Exporter** | `quay.io/navidys/prometheus-podman-exporter` | `docker.io/library/alpine` (Minimal) | Interacts with the Podman API socket to scrape container metrics. |
| **Promtail** | `docker.io/grafana/promtail` | `docker.io/library/alpine` (Minimal) | Aggregates and forwards system and container logs to Grafana Loki. |

---

## 🔒 Security Hardening Standards

Every container inside the Pod runs under strict security constraints:
- **No Root Execution:** Every process runs under unprivileged UIDs (`USER 1000`).
- **Read-Only Root Filesystem:** Prevents runtime mutations in the container filesystem (`readOnlyRootFilesystem: true`).
- **Privilege Escalation Blocked:** Zero chance of container escapes (`allowPrivilegeEscalation: false`).
- **Dropped Capabilities:** Drops all default Linux kernel capabilities (`capabilities: drop: [ALL]`).
- **No unnecessary binaries:** Built from clean minimal images containing zero compilers or build tools.

---

## ⚙️ Configuration & Environment

The stack is configured using `.env` files located under `env/`:

- **Local Development:** `env/local.env` (uses rootless user paths, e.g. `/run/user/1000/podman/podman.sock`).
- **Production Server:** `env/prod.env` (uses system-wide socket `/run/man/podman/podman.sock`).

### Configuration parameters:
```ini
PROJECT_NAME=monitor
NETWORK_NAME=monitor-network

PORT_NODE_EXPORTER=9100
PORT_PODMAN_EXPORTER=9882

PODMAN_SOCK=/run/podman/podman.sock # Path to the Podman API Socket

# Promtail / Loki configuration
OCI_NETBIRD_IP=100.92.64.40         # IP of the central Loki instance
MONITOR_NODE_NAME=vps-prod           # Identifier label for logs and metrics
JOURNAL_PATH=/run/log/journal        # Path to systemd journal on the host
```

---

## 🚀 Deployment Guide

### Prerequisite: Enable Podman API Socket
The Podman API socket must be listening on the host to allow the exporter to scrape metrics:

```bash
# For system-wide (root) deployments:
sudo systemctl enable --now podman.socket

# For user-space (rootless) deployments:
systemctl --user enable --now podman.socket
```

### Step 1: Compile Images
Build the secure and minimal images locally:
```bash
./scripts/build_images.sh
```

### Step 2: Production Deployment
To install and run the monitor stack as a system-wide Systemd service on the host:
```bash
sudo ./scripts/deploy_prod.sh
```

### Step 3: Service Management
Once deployed via Quadlets, manage the service using standard Systemd commands:
```bash
# Start the monitor
systemctl start monitor.service

# Check real-time status
systemctl status monitor.service

# View live logs
journalctl -u monitor.service -f

# Stop the monitor
systemctl stop monitor.service
```

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
