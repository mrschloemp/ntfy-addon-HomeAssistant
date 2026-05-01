#FROM binwiederhier/ntfy
#EXPOSE 80/tcp
#COPY server.yml /etc/ntfy/server.yml
#ENTRYPOINT ["ntfy", "serve"]
FROM binwiederhier/ntfy
# Wir kopieren NICHTS rein, damit GitHub nichts speichert
# Wir starten ntfy und sagen ihm: Schau in den HA-Config-Ordner!
ENTRYPOINT ["ntfy", "serve", "--config", "/config/ntfy/server.yml"]
