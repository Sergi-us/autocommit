#!/bin/sh

# Autocommit-BIT (Back In Time) Skript
# Inspiriert von https://github.com/antfu/1990-script
# Erstellt rückwirkende Commits für GitHub-Beitragsgrafik

# Konfiguration
PROJECT_DIR="$HOME/autocommit"
TARGET_YEAR="1990"  # Das Jahr, in dem du Commits erstellen möchtest
CITY="Berlin"       # Stadt für Wetterinformationen

# Generiere eine zufällige Zahl zwischen 0 und 7
x=$(shuf -i 1-20 -n 1)

# Bei 0 beenden wir das Skript ohne Commits
if [ $x = 0 ]; then
    exit
fi

# Erstelle das Jahresverzeichnis, falls es nicht existiert
YEAR_DIR="$PROJECT_DIR/$TARGET_YEAR"
mkdir -p "$YEAR_DIR"

# Funktion zum Erstellen eines Commits mit einem bestimmten Datum
create_commit_for_date() {
    local commit_date="$1"
    local commit_ts="$2"

    # Erstelle den Eintrag
    weather=$(curl -s "wttr.in/$CITY?format=4")
    echo "$commit_date - $commit_ts - Wetter in $weather" >> "$YEAR_DIR/history.txt"

    # Commit mit dem spezifischen Datum
    git -C "$PROJECT_DIR" add .
    GIT_AUTHOR_DATE="$commit_date" GIT_COMMITTER_DATE="$commit_date" \
    git -C "$PROJECT_DIR" commit -m "back in time - $commit_ts"
}

# Generiere x zufällige Tage im angegebenen Jahr
for i in $(seq 1 $x); do
    # Generiere ein zufälliges Datum im angegebenen Jahr
    # Berechne die Anzahl der Tage im Jahr (365 oder 366 für Schaltjahre)
    days_in_year=365
    is_leap_year=$(date -d "$TARGET_YEAR-02-29" +%Y-%m-%d 2>/dev/null)
    if [ -n "$is_leap_year" ]; then
        days_in_year=366
    fi

    # Zufälliger Tag im Jahr (1-365/366)
    random_day=$(shuf -i 1-$days_in_year -n 1)

    # Konvertiere in ein Datum
    random_date=$(date -d "$TARGET_YEAR-01-01 +$(($random_day - 1)) days" +"%Y-%m-%d")

    # Zufällige Uhrzeit zwischen 9:00 und 18:00
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
