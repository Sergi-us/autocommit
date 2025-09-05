#!/bin/sh
# matrix-commit.sh – Commit-Matrix (SARBS) für ein bestimmtes Jahr

# Konfiguration
PROJECT_DIR="$HOME/autocommit"
TARGET_YEAR="1990"  # Jahr der Commits
# AUTHOR="AutoCommit <you@example.com>"

# Matrix 52x7 (SARBS Pixelart)
# 0 = kein Commit, 1 = hellgrün, 2 = grün, 3 = dunkelgrün
MATRIX="
0000000000000000000000000000000000000000000000000000000000
0111100111100111101111011110011110000000000000000000000000
0100000100000100001000010001010001000000000000000000000000
0111000111100111001110011110011100000000000000000000000000
0001000100000100001000010001010001000000000000000000000000
0111100111100100001111010001011110000000000000000000000000
0000000000000000000000000000000000000000000000000000000000
"

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

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
                file="year-$TARGET_YEAR/week-$week/day-$day-$i.txt"
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
