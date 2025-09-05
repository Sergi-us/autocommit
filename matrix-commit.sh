#!/bin/sh
# matrix-commit.sh – schreibe GitHub-Commit-Matrix oder resette ein Jahr
# KISS / suckless Style

REPO_DIR="."    # Arbeitsverzeichnis (Repo)
AUTHOR="AutoCommit <you@example.com>"

# Matrix 52x7 (SARBS Pixelart, stark vereinfachte Demo)
# 0 = kein Commit, 1 = hellgrün, 2 = grün, 3 = dunkelgrün
# MO = erste Zeile, dann DI, ..., SO
# Du kannst die Werte beliebig ändern
MATRIX="
0000222000000003000000033300300000000000000000000000002
0003000300000030300000030030300000000000000000000000002
0003000000000300030000030030300000000000000000000000002
0000222000003000003000030300300000000000000000000000002
0000000300032222222300033000300000000000000000000000002
0003000300300000000030030300300000000000000000000000002
0000222003000000000003030030300000000000000000000000002
"

weekday_to_num() {
    # MO=0, DI=1 ... SO=6
    case "$1" in
        0) echo "Mon";;
        1) echo "Tue";;
        2) echo "Wed";;
        3) echo "Thu";;
        4) echo "Fri";;
        5) echo "Sat";;
        6) echo "Sun";;
    esac
}

write_matrix() {
    YEAR=$1
    START=$(date -d "$YEAR-01-01" +%u) # Wochentag des 1. Jan (1=Mo..7=So)
    FIRST_MONDAY=$(date -d "$YEAR-01-01 +$(( (8-START) % 7 )) days" +%Y-%m-%d)

    week=0
    day=0
    echo "$MATRIX" | while read -r line; do
        [ -z "$line" ] && continue
        week=0
        for c in $(echo "$line" | sed 's/./& /g'); do
            if [ "$c" != " " ] && [ "$c" != "0" ]; then
                date=$(date -d "$FIRST_MONDAY +$((week*7+day)) days" +%Y-%m-%d)
                count=$c
                i=1
                while [ $i -le $count ]; do
                    GIT_AUTHOR_DATE="$date 12:00:00" \
                    GIT_COMMITTER_DATE="$date 12:00:00" \
                    git -C "$REPO_DIR" commit --allow-empty -m "matrix $date" \
                        --author="$AUTHOR"
                    i=$((i+1))
                done
            fi
            week=$((week+1))
        done
        day=$((day+1))
    done
}

reset_year() {
    YEAR=$1
    git -C "$REPO_DIR" filter-branch --commit-filter '
        if [ "$(date -d "$GIT_COMMITTER_DATE" +%Y)" = "'"$YEAR"'" ];
        then skip_commit "$@";
        else git commit-tree "$@";
        fi' -- --all
}

case "$1" in
    write)
        [ -z "$2" ] && { echo "usage: $0 write <year>"; exit 1; }
        write_matrix "$2"
        ;;
    reset)
        [ -z "$2" ] && { echo "usage: $0 reset <year>"; exit 1; }
        reset_year "$2"
        ;;
    *)
        echo "usage: $0 write <year> | reset <year>"
        ;;
esac
