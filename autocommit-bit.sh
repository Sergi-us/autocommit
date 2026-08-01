#!/bin/sh

# Autocommit-BIT (Back In Time) Skript
# Inspiriert von https://github.com/antfu/1990-script
# Erstellt rückwirkende Commits für GitHub-Beitragsgrafik

set -e

# Konfiguration
PROJECT_DIR="$HOME/autocommit"
TARGET_YEAR="1990"  # Das Jahr, in dem du Commits erstellen möchtest
CITY="Berlin"       # Stadt für Wetterinformationen

# Wetter einmalig fetchen (vor der Schleife)
# -s = silent, 2>/dev/null = Fehler unterdrücken, || = Fallback
WEATHER=$(curl -s "wttr.in/$CITY?format=4" 2>/dev/null) || WEATHER="unbekannt"

# Generiere eine zufällige Zahl zwischen 0 und 5
# 0-5 = 0 ist möglich (keine Commits), 1-5 = Anzahl der Commits
x=$(shuf -i 0-5 -n 1)

# Bei 0 beenden wir das Skript ohne Commits
# Das sorgt für unvorhersehbare Tage ohne Commits im Diagramm
if [ "$x" = 0 ]; then
    exit 0
fi

# Erstelle das Jahresverzeichnis, falls es nicht existiert
YEAR_DIR="$PROJECT_DIR/$TARGET_YEAR"
mkdir -p "$YEAR_DIR"

# Funktion zum Erstellen eines Commits mit einem bestimmten Datum
# local = lokale Variablen in der Funktion
create_commit_for_date() {
    local commit_date="$1"
    local commit_ts="$2"

    # Erstelle den Eintrag in history.txt
    echo "$commit_date - $commit_ts - Wetter in $WEATHER" >> "$YEAR_DIR/history.txt"

    # Commit mit spezifischem Datum (GIT_AUTHOR_DATE/GIT_COMMITTER_DATE)
    # Das Datum wird für die Git-Historie verwendet, nicht das aktuelle Datum
    git -C "$PROJECT_DIR" add "$YEAR_DIR/history.txt"
    GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" \
    git -C "$PROJECT_DIR" commit -m "back in time - $commit_ts"
}

# Prüfe auf Schaltjahr (29. Februar existiert oder nicht)
days_in_year=365
if date -d "$TARGET_YEAR-02-29" >/dev/null 2>&1; then
    days_in_year=366
fi

# Generiere x zufällige Tage im angegebenen Jahr
for i in $(seq 1 "$x"); do
    # Zufälliger Tag im Jahr (1-365 oder 1-366)
    random_day=$(shuf -i 1-"$days_in_year" -n 1)

    # Konvertiere Tag-Nummer in Datum
    random_date=$(date -d "$TARGET_YEAR-01-01 +$((random_day - 1)) days" +%Y-%m-%d)

    # Zufällige Uhrzeit zwischen 9:00 und 18:00 (Arbeitszeit-Optik)
    random_hour=$(shuf -i 9-18 -n 1)
    random_minute=$(shuf -i 0-59 -n 1)
    random_second=$(shuf -i 0-59 -n 1)

    # Vollständiges Datum mit Zeit
    commit_date="$random_date $random_hour:$random_minute:$random_second"

    # Unix-Timestamp für dieses Datum
    commit_ts=$(date -d "$commit_date" +%s)

    # Erstelle den Commit
    create_commit_for_date "$commit_date" "$commit_ts"
done

# Push alle Änderungen
git -C "$PROJECT_DIR" push origin main

echo "Erstellt $x Commits im Jahr $TARGET_YEAR"
