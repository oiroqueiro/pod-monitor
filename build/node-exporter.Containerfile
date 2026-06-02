# # -------------------------------------------------------------------------
# CONSTRUCCIÓN ENDURECIDA: Node Exporter (Distroless)
# # -------------------------------------------------------------------------
FROM quay.io/prometheus/node-exporter:latest AS source
FROM docker.io/library/alpine:latest

# Copiamos SU binario
COPY --from=source /bin/node_exporter /bin/node_exporter

USER 1000
EXPOSE 9100
ENTRYPOINT ["/bin/node_exporter"]