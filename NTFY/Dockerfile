#FROM binwiederhier/ntfy
#EXPOSE 80/tcp
#COPY server.yml /etc/ntfy/server.yml
#ENTRYPOINT ["ntfy", "serve"]
FROM binwiederhier/ntfy
#ENTRYPOINT ["ntfy", "serve", "--config", "/config/www/ntfy/server.yml"]
ENTRYPOINT ["ls", "-R", "/config"]
