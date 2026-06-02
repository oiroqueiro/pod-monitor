#!/bin/bash
# # -------------------------------------------------------------------------
# SCRIPT DE CONSTRUCCIÓN: Imágenes Hardened para Monitorización
# # -------------------------------------------------------------------------

echo "[INFO] 1/3: Compilando distroless para node-exporter..."
podman build -t localhost/monitor-node-exporter:hardened -f build/node-exporter.Containerfile .

echo "[INFO] 2/3: Compilando distroless para podman-exporter..."
podman build -t localhost/monitor-podman-exporter:hardened -f build/podman-exporter.Containerfile .

echo "[INFO] 3/3: Compilando distroless para prometheus..."
podman build -t localhost/monitor-prometheus:hardened -f build/prometheus.Containerfile .

echo "# -------------------------------------------------------------------------"
echo "[OK] Proceso terminado. Comprobando las imágenes en el registro local:"
podman images | grep monitor-