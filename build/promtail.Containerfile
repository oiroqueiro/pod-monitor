# # -------------------------------------------------------------------------
# CONSTRUCCIÓN ENDURECIDA: Promtail (Distroless)
# # -------------------------------------------------------------------------
FROM docker.io/grafana/promtail:3.6.5 AS source
FROM docker.io/library/alpine:latest

# Copiamos su binario
COPY --from=source /usr/bin/promtail /usr/bin/promtail

USER 1000
ENTRYPOINT ["/usr/bin/promtail"]
