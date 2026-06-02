# # -------------------------------------------------------------------------
# CONSTRUCCIÓN ENDURECIDA: Prometheus (Wolfi Base)
# # -------------------------------------------------------------------------
FROM docker.io/prom/prometheus:latest AS source
FROM docker.io/library/alpine:latest

# Copiamos los binarios principales (la UI web ya viene embebida en el binario)
COPY --from=source /bin/prometheus /bin/prometheus
COPY --from=source /bin/promtool /bin/promtool

# Preparamos los directorios de configuración y datos, asignando el UID 1000
RUN mkdir -p /etc/prometheus /prometheus && \
    chown -R 1000:1000 /etc/prometheus /prometheus

# Cambiamos al usuario sin privilegios
USER 1000
EXPOSE 9090

# Punto de entrada apuntando a las rutas internas y limpiando parámetros obsoletos
ENTRYPOINT [ \
  "/bin/prometheus", \
  "--config.file=/etc/prometheus/prometheus.yml", \
  "--storage.tsdb.path=/prometheus" \
]