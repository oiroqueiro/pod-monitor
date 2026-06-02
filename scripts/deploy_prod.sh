#!/bin/bash
# # -------------------------------------------------------------------------
# SCRIPT DE DESPLIEGUE EN PRODUCCIÓN: Quadlet para Podman Monitor (System-wide)
# # -------------------------------------------------------------------------

export PROJECT_DIR=$(cd "$(dirname "$0")/.." && pwd)
QUADLET_DIR="/etc/containers/systemd"
DOTENV_FILE="$PROJECT_DIR/env/prod.env"

cd "$PROJECT_DIR"

if [ ! -f "$DOTENV_FILE" ]; then
    echo "[ERROR] No se encuentra el archivo de entorno de producción: $DOTENV_FILE"
    exit 1
fi

# 1. Exportar variables de entorno de producción
set -a
source "$DOTENV_FILE"
set +a

# 2. Asegurar que la red existe en Podman (a nivel de sistema/root)
podman network exists ${NETWORK_NAME} || podman network create ${NETWORK_NAME}

# 3. Preparar directorios de datos y permisos (UID/GID 1000 para Prometheus)
echo "[INFO] Preparando volúmenes locales y permisos (UID/GID 1000)..."
mkdir -p "$PROJECT_DIR/data/prometheus"
chown -R 1000:1000 "$PROJECT_DIR/data/prometheus"

# 4. Generación dinámica
echo "[INFO] Generando archivos estáticos con envsubst..."
envsubst < "$PROJECT_DIR/config/prometheus.yml" > "$PROJECT_DIR/config/prometheus.generated.yml"
envsubst < "$PROJECT_DIR/manifests/monitor.yaml" > "$PROJECT_DIR/manifests/monitor.generated.yaml"
envsubst < "$PROJECT_DIR/quadlet/monitor.kube" > "$PROJECT_DIR/quadlet/monitor.generated.kube"

# 5. Enlaces simbólicos en la carpeta de Quadlets de Sistema
echo "[INFO] Creando enlaces simbólicos en $QUADLET_DIR..."
mkdir -p "$QUADLET_DIR"
rm -f "$QUADLET_DIR"/monitor.*

ln -sf "$PROJECT_DIR/quadlet/monitor.generated.kube" "$QUADLET_DIR/monitor.kube"
ln -sf "$PROJECT_DIR/manifests/monitor.generated.yaml" "$QUADLET_DIR/monitor.yaml"

# 6. Activación en Systemd
echo "[INFO] Recargando daemon de Systemd..."
systemctl daemon-reload

echo "# -------------------------------------------------------------------------"
echo "✅ Stack 'monitor' consolidado en producción e integrado con Systemd (Modo Global)."
echo ""
echo "🚀 Instrucciones de gestión del servicio:"
echo "----------------------------------------------------------------"
echo "  Arrancar:    systemctl start monitor.service"
echo "  Estado:      systemctl status monitor.service"
echo "  Logs:        journalctl -u monitor.service -f"
echo "  Detener:     systemctl stop monitor.service"
echo "----------------------------------------------------------------"
