#!/bin/sh

# Autocommit-Daily Skript
# Erstellt tägliche Dateien für Wetterdaten und ordnet sie nach dem Format Jahr-Kalenderwoche-Wochentag

# Konfiguration
PROJECT_DIR="$HOME/.local/src/autocommit"
DAILY_DIR="$PROJECT_DIR/daily"
CITY="Berlin"       # Stadt für Wetterinformationen

# Generiere eine zufällige Zahl zwischen 0 und 7
x=$(shuf -i 0-70 -n 1)

# Bei 0 beenden wir das Skript ohne Commits
if [ $x = 0 ]; then
    exit
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

# Führe die folgenden Befehle x-mal aus (zwischen 1 und 7 Mal)
for i in $(seq 1 $x); do
    # Generiere einen Unix-Zeitstempel (Sekunden seit 01.01.1970)
    ts=$(date +%s)

    # Hole das aktuelle Wetter für die angegebene Stadt
    weather=$(curl -s "wttr.in/$CITY?format=4")

    # Schreibe einen Eintrag mit Datum, Zeitstempel und Wetter in die tägliche Datei
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $ts - Wetter in $weather" >> "$today_file"

    # Führe Git-Befehle aus, um die Änderungen zu committen und zu pushen
    git -C "$PROJECT_DIR" add .
    git -C "$PROJECT_DIR" commit -m "daily update - $date_format - $ts"
done

# Push alle Änderungen
git -C "$PROJECT_DIR" push origin main

echo "Erstellt $x Einträge für $date_format"
