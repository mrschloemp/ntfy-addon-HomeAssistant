#FROM binwiederhier/ntfy
#EXPOSE 80/tcp
#COPY server.yml /etc/ntfy/server.yml
#ENTRYPOINT ["ntfy", "serve"]
FROM binwiederhier/ntfy

# Wir starten ntfy und zeigen direkt auf den gemappten Pfad
ENTRYPOINT ["ntfy", "serve", "--config", "/config/ntfy/server.yml"]
