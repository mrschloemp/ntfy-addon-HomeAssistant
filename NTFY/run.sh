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
attachment-cache-dir: "/data/attachments"
attachment-total-size-limit: "1G"
attachment-file-size-limit: "15M"
attachment-expiry-duration: "24h"
EOF

echo "server.yml geschrieben"

# Auth-DB initialisieren falls sie nicht existiert
if [ ! -f "$NTFY_AUTH_FILE" ]; then
    echo "Initialisiere Auth-DB..."
    ntfy serve &
    SERVER_PID=$!
    sleep 5
    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null
    echo "Auth-DB bereit: $(ls -la $NTFY_AUTH_FILE 2>/dev/null || echo 'FEHLER')"
fi

# Admin-User anlegen ODER Passwort aktualisieren
if [ "$ADMIN_USER" != "null" ] && [ "$ADMIN_PASS" != "null" ]; then
    echo "Setze Admin-User: $ADMIN_USER"
    export NTFY_PASSWORD="$ADMIN_PASS"

    if ! ntfy user add --role=admin "$ADMIN_USER" 2>/dev/null; then
        echo "Admin existiert bereits, aktualisiere Passwort..."
        ntfy user change-pass "$ADMIN_USER"
    fi

    ntfy access everyone "*" deny 2>/dev/null || true
fi

# Zusätzliche User aus der Liste anlegen/aktualisieren
USER_COUNT=$(jq '.users | length' $OPTIONS_FILE)
if [ "$USER_COUNT" -gt 0 ]; then
    echo "Verarbeite $USER_COUNT zusätzliche User..."
    i=0
    while [ $i -lt $USER_COUNT ]; do
        USERNAME=$(jq --raw-output ".users[$i].username" $OPTIONS_FILE)
        PASSWORD=$(jq --raw-output ".users[$i].password" $OPTIONS_FILE)

        if [ "$USERNAME" != "null" ] && [ "$PASSWORD" != "null" ]; then
            echo "Setze User: $USERNAME"
            export NTFY_PASSWORD="$PASSWORD"

            if ! ntfy user add --role=user "$USERNAME" 2>/dev/null; then
                echo "User $USERNAME existiert bereits, aktualisiere Passwort..."
                ntfy user change-pass "$USERNAME"
            fi
        fi

        i=$((i + 1))
    done
fi

echo "--- ntfy Server startet auf Port $PORT ---"

exec ntfy serve
