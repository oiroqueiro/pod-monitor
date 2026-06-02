> [!NOTE]
> Este proyecto y toda su documentación han sido generados automática y completamente por **Gemini** desde **Antigravity**.

# 📊 Podman Monitor: Hardened Observability Stack

A state-of-the-art, high-performance, and **secure-by-design** system monitoring stack. This project packages **Node Exporter**, **Podman Exporter**, and **Prometheus** into a single Pod using rootless/system-wide **Podman** and **Quadlets**, integrated natively with Linux `systemd`.

This stack is designed to send host and container metrics securely to a central Prometheus server using Prometheus `remote_write` over a private network interface (e.g. Netbird VPN).

---

## 🏗️ Architecture & Component Stack

The stack consolidates three core monitoring services into a single systemd-managed Pod:

| Component | Upstream Image | Hardened Base Image | Purpose & Scope |
| :--- | :--- | :--- | :--- |
| **Node Exporter** | `quay.io/prometheus/node-exporter` | `docker.io/library/alpine` (Minimal) | Captures OS-level metrics (CPU, RAM, Disk, IO). |
| **Podman Exporter** | `quay.io/navidys/prometheus-podman-exporter` | `docker.io/library/alpine` (Minimal) | Interacts with the Podman API socket to scrape container metrics. |
| **Prometheus** | `docker.io/prom/prometheus` | `docker.io/library/alpine` (Minimal) | Aggregates local metrics and forwards them via `remote_write` to the central hub. |

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

# Observability relay
PROMETHEUS_CENTRAL=10.0.0.1         # IP of the central Prometheus instance (example)
MONITOR_NODE_NAME=vps-prod           # Identifier label for metrics

PORT_NODE_EXPORTER=9100
PORT_PODMAN_EXPORTER=9882
PORT_PROMETHEUS=9090

PODMAN_SOCK=/run/podman/podman.sock # Path to the Podman API Socket
```

---

## 🚀 Deployment Guide

### Prerequisite: Habilitar Socket de Podman
The Podman API socket must be listening on the host to allow the exporter to scrape metrics:

```bash
# Para despliegues a nivel de sistema (root):
sudo systemctl enable --now podman.socket

# Para despliegues de usuario (rootless):
systemctl --user enable --now podman.socket
```

### Paso 1: Compilar Imágenes
Compila de forma local las imágenes minimalistas y seguras:
```bash
./scripts/build_images.sh
```

### Paso 2: Despliegue en Producción
Para instalar y arrancar la monitorización como un servicio global de Systemd en el host:
```bash
sudo ./scripts/deploy_prod.sh
```

### Paso 3: Gestión del Servicio
Una vez desplegado con Quadlets, puedes controlar el servicio usando comandos estándar de Systemd:
```bash
# Arrancar el monitor
systemctl start monitor.service

# Ver el estado en tiempo real
systemctl status monitor.service

# Inspeccionar logs en caliente
journalctl -u monitor.service -f

# Detener el monitor
systemctl stop monitor.service
```

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
