# # -------------------------------------------------------------------------
# CONSTRUCCIÓN ENDURECIDA: Podman Exporter (Distroless)
# # -------------------------------------------------------------------------
FROM quay.io/navidys/prometheus-podman-exporter:latest AS source
FROM docker.io/library/alpine:latest

# Copiamos SU binario (la ruta que descubrimos con el inspect)
COPY --from=source /bin/podman_exporter /bin/podman_exporter

USER 1000
EXPOSE 9882
ENTRYPOINT ["/bin/podman_exporter"]