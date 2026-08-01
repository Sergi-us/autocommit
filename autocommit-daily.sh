#!/bin/sh

# Autocommit-Daily Skript
# Erstellt tägliche Dateien für Wetterdaten und ordnet sie nach dem Format Jahr-Kalenderwoche-Wochentag

set -e

# Konfiguration
PROJECT_DIR="$HOME/autocommit"
DAILY_DIR="$PROJECT_DIR/daily"
CITY="Berlin"       # Stadt für Wetterinformationen

# Wetter einmalig fetchen (vor der Schleife)
# -s = silent, keine Fortschrittsanzeige
# 2>/dev/null = Fehler unterdrücken
# || "unbekannt" = Fallback wenn curl fehlschlägt
WEATHER=$(curl -s "wttr.in/$CITY?format=4" 2>/dev/null) || WEATHER="unbekannt"

# Generiere eine zufällige Zahl zwischen 0 und 5
# 0-5 = mehr "0" Fälle = natürlichere Lücken im GitHub-Beitragsdiagramm
# shuf -i 0-5 = Zahlen 0,1,2,3,4,5 (6 Optionen)
# -n 1 = nur eine Zahl ausgeben
x=$(shuf -i 0-5 -n 1)

# Bei 0 beenden wir das Skript ohne Commits
# Das sorgt für unvorhersehbare Lücken im Beitragsdiagramm
if [ "$x" = 0 ]; then
    exit 0
fi

# Erstelle das Daily-Verzeichnis, falls es nicht existiert
mkdir -p "$DAILY_DIR"

# Aktuelles Datum im Format Jahr-Kalenderwoche-Wochentag
current_year=$(date +%Y)
current_week=$(date +%V)  # ISO-8601 Kalenderwoche (01-53)
current_day=$(date +%u)   # ISO-8601 Wochentag (1-7, 1 = Montag)
date_format="${current_year}-${current_week}-${current_day}"

# Dateiname für heute
today_file="$DAILY_DIR/$date_format.txt"

# Führe die folgenden Befehle x-mal aus (zwischen 1 und 5 Mal)
# seq 1 $x erzeugt Sequenz von 1 bis x
for i in $(seq 1 "$x"); do
    # Unix-Zeitstempel (Sekunden seit 01.01.1970)
    ts=$(date +%s)

    # Schreibe Eintrag mit Zeitstempel und Wetter
    # >> = an Datei anhängen (nicht überschreiben)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $ts - Wetter in $WEATHER" >> "$today_file"

    # Git-Befehle: -C = im Verzeichnis ausführen (nicht aktuelles Arbeitsverzeichnis)
    # add nur die spezifische Datei, nicht alles
    git -C "$PROJECT_DIR" add "$today_file"
    git -C "$PROJECT_DIR" commit -m "daily update - $date_format - $ts"
done

# Push alle Änderungen
git -C "$PROJECT_DIR" push origin main

echo "Erstellt $x Einträge für $date_format"
