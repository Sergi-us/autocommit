#!/bin/sh
# matrix-commit.sh – Commit-Matrix (SARBS) für ein bestimmtes Jahr

# Konfiguration
TARGET_YEAR="1990"  # Jahr der Commits
AUTHOR="AutoCommit <you@example.com>"

# Repo-Verzeichnisse
REPO_DIR=$(pwd)
YEAR_DIR="$REPO_DIR/$TARGET_YEAR"

# Matrix 52x7 (SARBS Pixelart)
MATRIX="
1111111111111111111111111111111111111111111111111111111111
1111100111100111101111011110011110000000000000000000000003
1100000100000100001000010001010001000000000000000000000003
1111000111100111001110011110011100000000000000000000000003
1001000100000100001000010001010001000000000000000000000003
1111100111100100001111010001011110000000000000000000000003
1111111111111111111111111111111111111111111111111111111111
"

# Repo initialisieren, falls nicht vorhanden
[ -d .git ] || git init

# Startdatum: erster Montag des Jahres
START=$(date -d "$TARGET_YEAR-01-01" +%u) # 1=Mo .. 7=So
FIRST_MONDAY=$(date -d "$TARGET_YEAR-01-01 +$(( (8-START) % 7 )) days" +%Y-%m-%d)

week=0
day=0

echo "$MATRIX" | while read -r line; do
    [ -z "$line" ] && continue
    week=0
    for c in $(echo "$line" | sed 's/./& /g'); do
        [ "$c" = " " ] && continue
        if [ "$c" != "0" ]; then
            date=$(date -d "$FIRST_MONDAY +$((week*7+day)) days" +%Y-%m-%d)
            count=$c
            i=1
            while [ $i -le $count ]; do
                file="$YEAR_DIR/week-$week/day-$day-$i.txt"
                mkdir -p "$(dirname "$file")"
                echo "$date $i" > "$file"
                GIT_AUTHOR_DATE="$date 12:00:00" \
                GIT_COMMITTER_DATE="$date 12:00:00" \
                git add "$file" && \
                git commit -m "matrix $date" --author="$AUTHOR"
                i=$((i+1))
            done
        fi
        week=$((week+1))
    done
    day=$((day+1))
done
