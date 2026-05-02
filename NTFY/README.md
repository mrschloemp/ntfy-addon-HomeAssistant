![WebApp](https://github.com/mrschloemp/ntfy-addon-HomeAssistant/blob/main/NTFY/ntfy-addon-config.png?raw=true)

## About
[ntfy](https://ntfy.sh/) (ausgesprochen „notify“) ist ein einfacher, HTTP-basierter Pub/Sub-Benachrichtigungsdienst. Er ermöglicht es Ihnen, Benachrichtigungen per Skript von jedem beliebigen Computer und/oder über eine REST-API an Ihr Smartphone oder Ihren Desktop-Computer zu senden. Die Software ist äußerst flexibel und komplett kostenlos.

Dieses Home-Assistant-Add-on verwendet eine ntfy-Instanz mit Standardeinstellungen.
Nach installation und Angabe der Berechtigungen, wie z.B. deaktiviertem Web UI, ist die Instanz nur noch über yml zu bedienen.
Beim Start des Addon werden die Berechtigungen in die Datenbank geschrieben. 
Mit Cloudflair Tunnel kann man eine Online Benachrichtigungsdienst erstellen, mit User, Topic Verwaltung über die Addon-Konfiguration.
Dieses Addon läuft in kombination mit der der 
[ntfy Integration von hbrennhaesuer](https://github.com/hbrennhaeuser/homeassistant_integration_ntfy).
Nach der Installation der hbrennhaeuser Integration wird in der configuration.yml der Benachrichtigungsdienst eingerichtet.
Vereinfacht verschickt nur der Admin die Benachrichtigungen. Für jeden Topic wird eine neue notification eingerichtet:
Yaml Vorlage:
### NTFY Integration 
notify:
  - name: ntfy_notification
    platform: ntfy
    authentication: 'user-pass'
    username: admin
    password: dein_sicheres_passwort
    url: 'https://deine_URL'
    topic: 'homeassistant'
    allow_topic_override: true
    attachment_maxsize: 15M
    
  - name: ntfy_notification_admin
    platform: ntfy
    authentication: 'user-pass'
    username: admin
    password: deinpasswort
    url: 'https://deien_URL'
    topic: 'admin'
    allow_topic_override: true
    attachment_maxsize: 15M


Weitere Informationen zur Verwendung finden Sie in der [ntfy Dokumentation](https://docs.ntfy.sh/).

[ntfy](https://ntfy.sh/) (pronounced notify) is a simple HTTP-based pub-sub notification service. It allows you to send notifications to your phone or desktop via scripts from any computer, and/or using a REST API. It's infinitely flexible, and 100% free software. <br>
<br>
This Home Assistant addon runs a ntfy instance with default settings - see the [ntfy docs](https://docs.ntfy.sh/) for more details on usage.
