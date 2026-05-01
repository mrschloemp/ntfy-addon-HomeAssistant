#!/bin/sh

OPTIONS_FILE="/data/options.json"

# 1. Globale Variablen setzen (Diese überschreiben JEDE Config-Datei)
export NTFY_AUTH_FILE="/data/auth.db"
export NTFY_CACHE_FILE="/data/cache.db"
export NTFY_AUTH_DEFAULT_ACCESS=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
export NTFY_BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
export NTFY_LISTEN_HTTP=":$(jq --raw-output '.listen_port' $OPTIONS_FILE)"
export NTFY_BEHIND_PROXY="true"

echo "--- ntfy Hard-Setup startet ---"

# Reset-Logik
RESET=$(jq --raw-output '.reset_data' $OPTIONS_FILE)
if [ "$RESET" = "true" ]; then
    echo "!!! RESET AKTIVIERT !!!"
    rm -f /data/*.db
fi

# 2. Admin-User anlegen (via Umgebungsvariablen)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
export NTFY_PASSWORD=$(jq --raw-output '.admin_password' $OPTIONS_FILE)

if [ "$ADMIN_USER" != "null" ]; then
    echo "Erzwinge Admin-User: $ADMIN_USER"
    touch $NTFY_AUTH_FILE
    ntfy user add --role=admin "$ADMIN_USER" || true
fi

echo "--- ntfy Start (Mode: $NTFY_AUTH_DEFAULT_ACCESS) ---"

# Wir starten ntfy OHNE das --config Flag, da die Umgebungsvariablen alles regeln
exec ntfy serve
echo "--- ntfy wird gestartet ---"
exec ntfy serve --config $CONFIG_FILE
