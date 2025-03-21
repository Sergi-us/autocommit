# Autocommit

Ein vielseitiges Toolkit zur automatischen Erstellung von Git-Commits. Ideal
für GitHub-Beitragsdiagramme, mit verschiedenen Skripten für tägliche Updates
oder rückwirkende Commits.

## Funktionen

- autocommit-daily.sh: Erstellt tägliche Dateien mit Wetterinformationen im
  Format Jahr-Kalenderwoche-Wochentag
- autocommit-bit.sh (Back In Time): Generiert rückwirkende Commits für
  vergangene Jahre
- Zufällige Anzahl von Commits bei jeder Ausführung (0-7)
- Organisiert Daten in separaten Verzeichnissen für einfache Verwaltung und
  Löschung
- Fügt aktuelle Wetterinformationen zu jedem Commit hinzu
- Einfaches Setup auf jedem Debian-basierten Server

## Voraussetzungen

- Debian-basierter Server (Ubuntu, Debian, etc.)
- Git
- curl
- cron
- SSH-Zugang zu GitHub

## Installation

### 1. Server-Vorbereitung

Neuen Nutzer erstellen und notwendige Pakete installieren:

```bash
# Als Root-Nutzer ausführen
adduser github
# Brauche ich unbedingt SUDO??
# usermod -aG sudo github
```

### 2. SSH-Setup

SSH-Schlüssel für den neuen Nutzer generieren:

```bash
# Als 'autocommit' Nutzer ausführen
su - autocommit
ssh-keygen -t ed25519 -C "autocommit@server"
# -t Schlüsselart
# -C Kommentar
cat ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/id_ed25519
chmod 700 ~/.ssh
```

Den angezeigten SSH-Schlüssel kopieren und zu GitHub hinzufügen:
- Gehe zu GitHub → Settings → SSH and GPG keys
- Klicke auf "New SSH key"
- Füge den kopierten Schlüssel ein und speichere

### 3. GitHub-Repository 'autocommit' erstellen oder Clone dieses Repo

Erstelle ein neues Repository auf GitHub und klone es:

```bash
# Als 'autocommit' Nutzer ausführen
git clone git@github.com:DEIN-USERNAME/autocommit.git
cd ~/autocommit
touch main.txt
git add main.txt
git commit -m "Initial commit"
git push origin main
```

### 4. Autocommit-Skript erstellen

Erstelle das Skript `autocommit.sh` Projektverzeichniss:

```bash
cd ~/autocommit
nvim autocommit.sh
```

Bearbeite oder füge den inhalt ein.

Mache das Skript ausführbar:

```bash
chmod +x ~/autocommit/autocommit.sh
```

### 5. Cronjob einrichten

Richte einen Cronjob ein, um das Skript regelmäßig auszuführen:

```bash
crontab -e
```

Füge folgende Zeile ein, um das Skript stündlich auszuführen:

```
@daily /home/github/autocommit/autocommit.sh
```

## Das Skript

Das `autocommit.sh` Skript:

```bash
#!/bin/sh
x=$(shuf -i 0-7 -n 1)
project_dir="$HOME/autocommit"
if [ $x = 0 ]; then
    exit
fi
for i in $(seq 1 $x);
do
    ts=$(date +%s)
    weather=$(curl -s "wttr.in/Berlin?format=4")
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $ts - Wetter in $weather" >> "$project_dir/main.txt"
    git -C $project_dir add .
    git -C $project_dir commit -m "auto commit - $ts"
    git -C $project_dir push origin main
done
```

## Funktionsweise

- Das Skript generiert eine Zufallszahl zwischen 0 und 7
- Bei 0 wird das Skript beendet, ohne Commits zu erzeugen
- Ansonsten werden 1 bis 7 Commits erstellt (abhängig von der Zufallszahl)
- Jeder Commit enthält einen Zeitstempel und aktuelle Wetterinformationen
- Die Daten werden in main.txt gespeichert und automatisch gepusht

## Lizenz

MIT

---

Viel Spaß mit dem automatischen Committing!
