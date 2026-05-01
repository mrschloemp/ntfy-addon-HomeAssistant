#FROM binwiederhier/ntfy
#EXPOSE 80/tcp
#COPY server.yml /etc/ntfy/server.yml
#ENTRYPOINT ["ntfy", "serve"]
FROM binwiederhier/ntfy
# WICHTIG: Im Container heißt der HA-Ordner immer /config
ENTRYPOINT ["ntfy", "serve", "--config", "/config/ntfy/server.yml"]
