#FROM binwiederhier/ntfy
#EXPOSE 80/tcp
#COPY server.yml /etc/ntfy/server.yml
#ENTRYPOINT ["ntfy", "serve"]
FROM binwiederhier/ntfy
# Wir versuchen den absoluten HA-Pfad anzusprechen
ENTRYPOINT ["ntfy", "serve", "--config", "/homeassistant/ntfy/server.yml"]
