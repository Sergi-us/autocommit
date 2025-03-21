#!/bin/sh

# Generiere eine zufällige Zahl zwischen 0 und 7
# Diese Zahl bestimmt, wie viele Commits erstellt werden
# shuf ist ein Linux-Tool zum Erzeugen von Zufallszahlen oder zum Mischen von Zeilen
# -i 0-7: Definiert den Zahlenbereich von 0 bis 7
# -n 1: Gibt nur eine Zahl aus
x=$(shuf -i 0-7 -n 1)

# Definiere den Pfad zum Repository
# $HOME bezieht sich auf das Home-Verzeichnis des ausführenden Nutzers
project_dir="$HOME/autocommit"

# Wenn die Zufallszahl 0 ist, beende das Skript sofort
# Dies fügt eine zusätzliche Zufälligkeit hinzu - in etwa 1/8 der Fälle
# werden gar keine Commits erstellt
# if-fi = bedingte Anweisung:
if [ $x = 0 ]; then
    exit
fi

# Führe die folgenden Befehle x-mal aus (zwischen 1 und 7 Mal)
# seq erzeugt eine Sequenz von Zahlen von 1 bis zum Wert von $x
for i in $(seq 1 $x);
do
    # Generiere einen Unix-Zeitstempel (Sekunden seit 01.01.1970)
    # Dies dient zur eindeutigen Identifizierung des Commits
    ts=$(date +%s)

    # Hole das aktuelle Wetter für Berlin von wttr.in
    # format=4 gibt das Wetter in einem kompakten Format zurück
    # curl -s stellt sicher, dass keine Fortschrittsanzeige ausgegeben wird
    weather=$(curl -s "wttr.in/Berlin?format=4")

    # Schreibe einen Eintrag mit Datum, Zeitstempel und Wetter in die main.txt Datei
    # >> fügt den Text am Ende der Datei hinzu (statt sie zu überschreiben)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $ts - Wetter in $weather" >> "$project_dir/main.txt"

    # Führe Git-Befehle aus, um die Änderungen zu committen und zu pushen
    # -C $project_dir bedeutet, dass Git im angegebenen Verzeichnis ausgeführt wird
    # (statt im aktuellen Arbeitsverzeichnis)
    git -C $project_dir add .
    git -C $project_dir commit -m "auto commit - $ts"
    git -C $project_dir push origin main
done

# Wenn das Skript über cron regelmäßig ausgeführt wird, ergibt sich ein
# unvorhersehbares Muster an Commits - manchmal keiner, manchmal mehrere.
