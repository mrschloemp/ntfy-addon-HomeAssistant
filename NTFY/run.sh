#!/bin/sh

OPTIONS_FILE="/data/options.json"

export NTFY_AUTH_FILE="/data/auth.db"
export NTFY_CACHE_FILE="/data/cache.db"
CONFIG_FILE="/data/server.yml"

BASE_URL=$(jq --raw-output '.base_url' $OPTIONS_FILE)
PORT=$(jq --raw-output '.listen_port' $OPTIONS_FILE)
AUTH_MODE=$(jq --raw-output '.auth_default_access' $OPTIONS_FILE)
ADMIN_USER=$(jq --raw-output '.admin_user' $OPTIONS_FILE)
ADMIN_PASS=$(jq --raw-output '.admin_password' $OPTIONS_FILE)

echo "--- ntfy Setup startet ---"

# Reset-Logik
if [ "$(jq --raw-output '.reset_data' $OPTIONS_FILE)" = "true" ]; then
    echo "!!! RESET AKTIVIERT !!!"
    rm -f "$NTFY_AUTH_FILE" "$NTFY_CACHE_FILE" "$CONFIG_FILE"
fi

# server.yml generieren (einige Optionen gibt es nur hier, nicht als CLI-Flag)
cat > "$CONFIG_FILE" <<EOF
base-url: "${BASE_URL}"
listen-http: ":${PORT}"
behind-proxy: true
auth-file: "${NTFY_AUTH_FILE}"
cache-file: "${NTFY_CACHE_FILE}"
auth-default-access: "${AUTH_MODE}"

# Sicherheit: Niemand kann sich selbst registrieren
enable-signup: false
enable-login: true

# Web-UI nur wenn eingeloggt sinnvoll nutzbar;
# komplett deaktivieren: web-root: "/"
web-root: "/"
EOF

echo "server.yml geschrieben"

# Admin-User anlegen ODER Passwort aktualisieren
if [ "$ADMIN_USER" != "null" ] && [ "$ADMIN_PASS" != "null" ]; then
    echo "Setze Admin-User: $ADMIN_USER"
    export NTFY_PASSWORD="$ADMIN_PASS"

    # Versuche anlegen; wenn User schon existiert, Passwort aktualisieren
    if ! ntfy user add --role=admin "$ADMIN_USER" 2>/dev/null; then
        echo "User existiert bereits, aktualisiere Passwort..."
        ntfy user change-pass "$ADMIN_USER"
    fi

    # Explizit: Anonyme dürfen gar nichts
    ntfy access everyone "*" deny 2>/dev/null || true
fi

echo "--- ntfy Server startet auf Port $PORT ---"

exec ntfy serve --config="$CONFIG_FILE"
