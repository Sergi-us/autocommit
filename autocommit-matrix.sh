#!/bin/sh
# autocommit-matrix.sh – Commit-Matrix (SARBS) für ein bestimmtes Jahr

set -e

# Konfiguration
TARGET_YEAR="2025"
AUTHOR="AutoCommit <you@example.com>"

# Verzeichnisse
PROJECT_DIR="$HOME/autocommit"
YEAR_DIR="$PROJECT_DIR/$TARGET_YEAR"

# Matrix 52x7 (SARBS Pixelart)
MATRIX="
0000000000111100001000011110001111000011110000000000
0000000001000000010100010001001000100100000000000000
0000000001000000100010010001001000100100000000000000
0000000000111000111110011110001111000011100000000000
0000000000000100100010010010001000100000010000000000
0000000000000100100010010001001000100000010000000000
0000000001111000100010010001001111000111100000000000
"

# Repo initialisieren falls nicht vorhanden
[ -d "$PROJECT_DIR/.git" ] || git -C "$PROJECT_DIR" init

# Startdatum: erster Montag des Jahres
START=$(date -d "$TARGET_YEAR-01-01" +%u)
FIRST_MONDAY=$(date -d "$TARGET_YEAR-01-01 +$(( (8-START) % 7 )) days" +%Y-%m-%d)

day=0

echo "$MATRIX" | while read -r line; do
    [ -z "$line" ] && continue

    week=0
    for char in $(echo "$line" | sed 's/./& /g'); do
        [ "$char" = " " ] && continue
        if [ "$char" != "0" ]; then
            commit_date=$(date -d "$FIRST_MONDAY +$((week*7+day)) days" +%Y-%m-%d)
            count="$char"
            i=1
            while [ "$i" -le "$count" ]; do
                file="$YEAR_DIR/week-$week/day-$day-$i.txt"
                mkdir -p "$(dirname "$file")"
                echo "$commit_date $i" > "$file"

                git -C "$PROJECT_DIR" add "$file"
                GIT_AUTHOR_DATE="$commit_date 12:00:00" \
                GIT_COMMITTER_DATE="$commit_date 12:00:00" \
                git -C "$PROJECT_DIR" commit -m "matrix $commit_date" --author="$AUTHOR"

                i=$((i+1))
            done
        fi
        week=$((week+1))
    done
    day=$((day+1))
done

echo "Matrix für $TARGET_YEAR erstellt"
