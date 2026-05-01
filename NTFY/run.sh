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
    echo "Lösche alte Datenbanken und Protokolle..."
    rm -f $AUTH_DB
    rm -f $CACHE_DB
    rm -f /data/*.db
    echo "Daten wurden bereinigt."
fi

# Werte auslesen
BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
PORT=$(jq --raw-output '.listen_port' $OPTIONS_FILE)
AUTH_MODE=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
ADMIN_PASS=$(jq --raw-output '.admin_password' $OPTIONS_FILE)

# 1. server.yml schreiben
cat <<EOF > $CONFIG_FILE
base-url: "$BASE_URL"
listen-http: ":$PORT"
auth-file: "$AUTH_DB"
cache-file: "$CACHE_DB"
auth-default-access: "$AUTH_MODE"
behind-proxy: true
EOF

# 2. Admin-Benutzer anlegen (nach einem Reset oder bei Neuinstallation)
if [ "$ADMIN_USER" != "null" ] && [ "$ADMIN_PASS" != "null" ]; then
    echo "Stelle Admin-Benutzer '$ADMIN_USER' sicher..."
    ntfy user add --auth-file="$AUTH_DB" --role=admin "$ADMIN_USER" "$ADMIN_PASS" || true
    ntfy access --auth-file="$AUTH_DB" "$ADMIN_USER" "*" read-write || true
fi

echo "--- ntfy wird gestartet ---"
exec ntfy serve --config $CONFIG_FILE
