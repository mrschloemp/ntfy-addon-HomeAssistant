#!/bin/sh

OPTIONS_FILE="/data/options.json"
CONFIG_FILE="/data/server.yml"
AUTH_DB="/data/auth.db"
CACHE_DB="/data/cache.db"

echo "--- ntfy Setup startet ---"

# Reset-Option prüfen
RESET=$(jq --raw-output '.reset_data' $OPTIONS_FILE)
if [ "$RESET" = "true" ]; then
    echo "!!! RESET-MODUS AKTIVIERT !!!"
    rm -f $AUTH_DB $CACHE_DB /data/*.db
    echo "Daten wurden bereinigt."
fi

# Werte auslesen
BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
PORT=$(jq --raw-output '.listen_port' $OPTIONS_FILE)
AUTH_MODE=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
export NTFY_PASSWORD=$(jq --raw-output '.admin_password' $OPTIONS_FILE)

# 1. server.yml schreiben
cat <<EOF > $CONFIG_FILE
base-url: "$BASE_URL"
listen-http: ":$PORT"
auth-file: "$AUTH_DB"
cache-file: "$CACHE_DB"
auth-default-access: "$AUTH_MODE"
behind-proxy: true
EOF

# 2. Admin-Benutzer anlegen
if [ "$ADMIN_USER" != "null" ] && [ "$NTFY_PASSWORD" != "null" ]; then
    echo "Stelle Admin-Benutzer '$ADMIN_USER' sicher..."
    
    # In ntfy 2.22.x nutzen wir die Umgebungsvariable und das config-Flag für den Pfad
    ntfy user add --config=$CONFIG_FILE --role=admin "$ADMIN_USER" || true
    
    # Berechtigungen setzen (hier wird das config-Flag genutzt, um die DB zu finden)
    echo "Setze Berechtigungen für $ADMIN_USER..."
    ntfy access --config=$CONFIG_FILE "$ADMIN_USER" "*" read-write || true
fi

echo "--- ntfy wird gestartet ---"
exec ntfy serve --config $CONFIG_FILE
