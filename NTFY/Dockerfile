FROM binwiederhier/ntfy

# Installiere jq, um die Home Assistant Optionen zu verarbeiten
RUN apk add --no-cache jq

# Start-Script kopieren und Rechte setzen
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
