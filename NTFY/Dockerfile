#FROM binwiederhier/ntfy
#EXPOSE 80/tcp
#COPY server.yml /etc/ntfy/server.yml
#ENTRYPOINT ["ntfy", "serve"]
FROM binwiederhier/ntfy
# Dieser Befehl zeigt uns JEDEN Ordner im System an
ENTRYPOINT ["find", "/", "-maxdepth", "2", "-not", "-path", "*/.*"]
