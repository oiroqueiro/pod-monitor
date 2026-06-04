#!/bin/bash
# # -------------------------------------------------------------------------
# SCRIPT DE DESPLIEGUE: Quadlet para Podman Monitor
# # -------------------------------------------------------------------------

export PROJECT_DIR=$(cd "$(dirname "$0")/.." && pwd)
QUADLET_DIR="$HOME/.config/containers/systemd"
DOTENV_FILE="$PROJECT_DIR/env/local.env"

cd "$PROJECT_DIR"

# 1. Exportar variables para envsubst
export $(grep -v '^#' "$DOTENV_FILE" | xargs)

# 2. Asegurar que la red existe en Podman
podman network exists ${NETWORK_NAME} || podman network create ${NETWORK_NAME}

# 4. Generación dinámica
echo "[INFO] Generando archivos estáticos con envsubst..."
envsubst < "$PROJECT_DIR/manifests/monitor.yaml" > "$PROJECT_DIR/manifests/monitor.generated.yaml"
envsubst < "$PROJECT_DIR/quadlet/monitor.kube" > "$PROJECT_DIR/quadlet/monitor.generated.kube"
envsubst < "$PROJECT_DIR/config/promtail.yml" > "$PROJECT_DIR/config/promtail.generated.yml"

# 5. Enlaces simbólicos en la carpeta del SO
echo "[INFO] Creando enlaces simbólicos en $QUADLET_DIR..."
mkdir -p "$QUADLET_DIR"
rm -f "$QUADLET_DIR"/monitor.*

ln -sf "$PROJECT_DIR/quadlet/monitor.generated.kube" "$QUADLET_DIR/monitor.kube"
ln -sf "$PROJECT_DIR/manifests/monitor.generated.yaml" "$QUADLET_DIR/monitor.yaml"

# 6. Activación en Systemd
echo "[INFO] Recargando daemon de Systemd..."
systemctl --user daemon-reload

echo "# -------------------------------------------------------------------------"
echo "✅ Stack 'monitor' consolidado e integrado con Systemd."
echo ""
echo "🚀 Instrucciones de gestión del servicio:"
echo "----------------------------------------------------------------"
echo "  Arrancar:    systemctl --user start monitor.service"
echo "  Estado:      systemctl --user status monitor.service"
echo "  Logs:        journalctl --user -u monitor.service -f"
echo "  Detener:     systemctl --user stop monitor.service"
echo "----------------------------------------------------------------"