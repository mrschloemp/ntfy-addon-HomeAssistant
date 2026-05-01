#!/bin/sh

OPTIONS_FILE="/data/options.json"
CONFIG_FILE="/data/server.yml"

# Globale Umgebungsvariablen (wie in den Docs empfohlen)
export NTFY_AUTH_FILE="/data/auth.db"
export NTFY_CACHE_FILE="/data/cache.db"

echo "--- ntfy Setup startet ---"

# Reset-Option prüfen
RESET=$(jq --raw-output '.reset_data' $OPTIONS_FILE)
if [ "$RESET" = "true" ]; then
    echo "!!! RESET-MODUS AKTIVIERT !!!"
    rm -f $NTFY_AUTH_FILE $NTFY_CACHE_FILE /data/*.db
    echo "Daten wurden bereinigt."
fi

# Werte auslesen
BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
PORT=$(jq --raw-output '.listen_port' $OPTIONS_FILE)
AUTH_MODE=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
export NTFY_PASSWORD=$(jq --raw-output '.admin_password' $OPTIONS_FILE)

# 1. Datenbank-Datei sicherheitshalber erstellen, falls sie fehlt
touch $NTFY_AUTH_FILE
chmod 0600 $NTFY_AUTH_FILE

# 2. server.yml schreiben
cat <<EOF > $CONFIG_FILE
base-url: "$BASE_URL"
listen-http: ":$PORT"
auth-file: "$NTFY_AUTH_FILE"
cache-file: "$NTFY_CACHE_FILE"
auth-default-access: "$AUTH_MODE"
behind-proxy: true
EOF

# 3. Admin-Benutzer anlegen
if [ "$ADMIN_USER" != "null" ] && [ "$NTFY_PASSWORD" != "null" ]; then
    echo "Stelle Admin-Benutzer '$ADMIN_USER' sicher..."
    # ntfy nutzt automatisch NTFY_AUTH_FILE und NTFY_PASSWORD
    ntfy user add --role=admin "$ADMIN_USER" || true
    
    echo "Setze Berechtigungen für $ADMIN_USER..."
    ntfy access "$ADMIN_USER" "*" read-write || true
fi

echo "--- ntfy wird gestartet ---"
exec ntfy serve --config $CONFIG_FILE
