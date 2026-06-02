> [!NOTE]
> Este proyecto y toda su documentación han sido desarrollados automática y completamente por **Gemini (Antigravity)** bajo la supervisión y gestión de **Oscar Iglesias Roqueiro** (@oiroqueiro).

# 📊 Podman Monitor: Stack de Observabilidad Endurecido

Un stack de monitoreo de sistemas de alto rendimiento, eficiente y **seguro por diseño**. Este proyecto empaqueta **Node Exporter**, **Podman Exporter** y **Prometheus** en un único Pod utilizando **Podman** (rootless o global) y **Quadlets**, integrado nativamente con Linux `systemd`.

Este stack está diseñado para enviar métricas del host y de los contenedores de forma segura a un servidor Prometheus central utilizando Prometheus `remote_write` a través de una interfaz de red privada (por ejemplo, el túnel VPN de Netbird).

---

## 🏗️ Arquitectura y Componentes del Stack

El stack consolida tres servicios principales en un único Pod administrado por Systemd:

| Componente | Imagen de Origen | Imagen Base Endurecida | Propósito y Alcance |
| :--- | :--- | :--- | :--- |
| **Node Exporter** | `quay.io/prometheus/node-exporter` | `docker.io/library/alpine` (Mínima) | Captura métricas a nivel de sistema operativo (CPU, RAM, Disco, E/S). |
| **Podman Exporter** | `quay.io/navidys/prometheus-podman-exporter` | `docker.io/library/alpine` (Mínima) | Se conecta al socket de la API de Podman para extraer métricas de los contenedores. |
| **Prometheus** | `docker.io/prom/prometheus` | `docker.io/library/alpine` (Mínima) | Agrega métricas locales y las reenvía mediante `remote_write` al servidor central. |

---

## 🔒 Estándares de Seguridad y Endurecimiento

Cada contenedor dentro del Pod se ejecuta bajo estrictas restricciones de seguridad:
- **Sin ejecución como Root:** Todos los procesos se ejecutan bajo UIDs sin privilegios (`USER 1000`).
- **Sistema de archivos de solo lectura:** Evita modificaciones en caliente del sistema de archivos del contenedor (`readOnlyRootFilesystem: true`).
- **Bloqueo de escalada de privilegios:** Imposibilidad total de escapes del contenedor (`allowPrivilegeEscalation: false`).
- **Capacidades eliminadas:** Se eliminan todas las capacidades por defecto del kernel de Linux (`capabilities: drop: [ALL]`).
- **Sin binarios innecesarios:** Compilado a partir de imágenes base limpias y mínimas sin herramientas de compilación ni shells innecesarias.

---

## ⚙️ Configuración y Variables de Entorno

El stack se configura utilizando los archivos `.env` ubicados en `env/`:

- **Desarrollo Local:** `env/local.env` (utiliza rutas de usuario rootless, ej. `/run/user/1000/podman/podman.sock`).
- **Servidor de Producción:** `env/prod.env` (utiliza el socket global del sistema `/run/podman/podman.sock`).

### Parámetros de configuración:
```ini
PROJECT_NAME=monitor
NETWORK_NAME=monitor-network

# Relevo de observabilidad
PROMETHEUS_CENTRAL=10.0.0.1         # IP del servidor Prometheus central (ejemplo)
MONITOR_NODE_NAME=vps-prod           # Identificador para las métricas

PORT_NODE_EXPORTER=9100
PORT_PODMAN_EXPORTER=9882
PORT_PROMETHEUS=9090

PODMAN_SOCK=/run/podman/podman.sock # Ruta del socket de la API de Podman
```

---

## 🚀 Guía de Despliegue

### Requisito previo: Habilitar el Socket de Podman
El socket de la API de Podman debe estar activo en el host para permitir que el exportador lea las métricas:

```bash
# Para despliegues globales de sistema (root):
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

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.
