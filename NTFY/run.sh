#!/bin/sh

OPTIONS_FILE="/data/options.json"

export NTFY_AUTH_FILE="/data/auth.db"
export NTFY_CACHE_FILE="/data/cache.db"
export NTFY_CONFIG_FILE="/data/server.yml"

BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
PORT=$(jq --raw-output '.listen_port' $OPTIONS_FILE)
AUTH_MODE=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
ADMIN_PASS=$(jq --raw-output '.admin_password' $OPTIONS_FILE)
WEB_UI=$(jq --raw-output '.enable_web_ui' $OPTIONS_FILE)

WEB_ROOT="/"
[ "$WEB_UI" = "true" ] && WEB_ROOT="/app"

echo "--- ntfy Setup startet ---"

# Reset-Logik
if [ "$(jq --raw-output '.reset_data' $OPTIONS_FILE)" = "true" ]; then
    echo "!!! RESET AKTIVIERT !!!"
    rm -f "$NTFY_AUTH_FILE" "$NTFY_CACHE_FILE" "$NTFY_CONFIG_FILE"
fi

# server.yml generieren
cat > "$NTFY_CONFIG_FILE" <<EOF
base-url: "${BASE_URL}"
listen-http: ":${PORT}"
behind-proxy: true
auth-file: "${NTFY_AUTH_FILE}"
cache-file: "${NTFY_CACHE_FILE}"
auth-default-access: "${AUTH_MODE}"
enable-signup: false
enable-login: true
web-root: "${WEB_ROOT}"
EOF

echo "server.yml geschrieben"

# Auth-DB anlegen: Server kurz starten damit ntfy die DB initialisiert
if [ ! -f "$NTFY_AUTH_FILE" ]; then
    echo "Initialisiere Auth-DB via Server-Start..."
    ntfy serve &
    SERVER_PID=$!
    sleep 5
    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null
    echo "Auth-DB bereit: $(ls -la $NTFY_AUTH_FILE 2>/dev/null || echo 'FEHLER: nicht erstellt')"
fi

# Admin-User anlegen ODER Passwort aktualisieren
if [ "$ADMIN_USER" != "null" ] && [ "$ADMIN_PASS" != "null" ]; then
    echo "Setze Admin-User: $ADMIN_USER"
    export NTFY_PASSWORD="$ADMIN_PASS"

    if ! ntfy user add --role=admin "$ADMIN_USER" 2>/dev/null; then
        echo "User existiert bereits, aktualisiere Passwort..."
        ntfy user change-pass "$ADMIN_USER"
    fi

    ntfy access everyone "*" deny 2>/dev/null || true
fi

echo "--- ntfy Server startet auf Port $PORT ---"

exec ntfy serve
