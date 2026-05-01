#!/bin/sh

OPTIONS_FILE="/data/options.json"

# Pfade festlegen
export NTFY_AUTH_FILE="/data/auth.db"
export NTFY_CACHE_FILE="/data/cache.db"

# Werte auslesen
BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
PORT=$(jq --raw-output '.listen_port' $OPTIONS_FILE)
AUTH_MODE=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
ADMIN_PASS=$(jq --raw-output '.admin_password' $OPTIONS_FILE)

echo "--- ntfy Setup startet ---"

# Reset-Logik (nur wenn Schalter in HA aktiv)
if [ "$(jq --raw-output '.reset_data' $OPTIONS_FILE)" = "true" ]; then
    echo "!!! RESET AKTIVIERT !!!"
    rm -f $NTFY_AUTH_FILE $NTFY_CACHE_FILE
fi

# Datenbank initialisieren
touch $NTFY_AUTH_FILE

# Admin-User erzwingen
if [ "$ADMIN_USER" != "null" ]; then
    echo "Aktualisiere Admin-User: $ADMIN_USER"
    export NTFY_PASSWORD="$ADMIN_PASS"
    ntfy user add --role=admin "$ADMIN_USER" || true
fi

echo "--- ntfy Server startet auf Port $PORT ---"

# Start mit allen Parametern
exec ntfy serve \
  --base-url="$BASE_URL" \
  --listen-http=":$PORT" \
  --auth-file="$NTFY_AUTH_FILE" \
  --cache-file="$NTFY_CACHE_FILE" \
  --auth-default-access="$AUTH_MODE" \
  --behind-proxy=true
