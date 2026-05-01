#!/bin/sh

OPTIONS_FILE="/data/options.json"
CONFIG_FILE="/data/server.yml"
AUTH_DB="/data/auth.db"

echo "--- ntfy Setup startet ---"

# Werte mit jq aus der options.json auslesen
BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
PORT=$(jq --raw-output '.listen_port' $OPTIONS_FILE)
AUTH_MODE=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
ADMIN_PASS=$(jq --raw-output '.admin_password' $OPTIONS_FILE)

# 1. server.yml erstellen
cat <<EOF > $CONFIG_FILE
# ntfy Konfiguration (automatisch generiert)
base-url: "$BASE_URL"
listen-http: ":$PORT"
auth-file: "$AUTH_DB"
auth-default-access: "$AUTH_MODE"
behind-proxy: true
EOF

# 2. Admin-Benutzer anlegen/aktualisieren
if [ "$ADMIN_USER" != "null" ] && [ "$ADMIN_PASS" != "null" ]; then
    echo "Stelle Admin-Benutzer '$ADMIN_USER' sicher..."
    # Erstellt den User oder aktualisiert das Passwort, falls er schon existiert
    ntfy user add --auth-file="$AUTH_DB" --role=admin "$ADMIN_USER" "$ADMIN_PASS" || true
fi

echo "--- ntfy wird jetzt gestartet ---"
echo "Erreichbar unter: $BASE_URL (Port: $PORT)"
echo "Standard-Zugriff: $AUTH_MODE"

exec ntfy serve --config $CONFIG_FILE
