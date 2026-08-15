# 🤖 Autocommit

**Toolkit zur automatischen Erstellung von Git-Commits**

> **🔄 Umzug zu Codeberg**: Die aktive Entwicklung und Kollaboration findet jetzt auf [Codeberg](https://codeberg.org/Sergius/autocommit) statt. GitHub dient nur als Mirror.

Ein vielseitiges Skript-Set für automatische Git-Commits – ideal für GitHub-Beitragsdiagramme, mit täglichen Updates oder rückwirkenden Commits.

## ✨ Features

- **autocommit-daily.sh** – Hauptskript: Tägliche Commits mit Wetterdaten, organisiert nach Jahr-Kalenderwoche-Tag
- **autocommit-bit.sh** (Back In Time) – Generiert rückwirkende Commits für vergangene Jahre
- **autocommit-matrix.sh** – Commit-Matrix: SARBS Pixelart im GitHub-Beitragsdiagramm
- **Zufällige Commits** – 0-5 (daily) / 0-20 (bit) pro Ausführung für natürliches Beitragsdiagramm
- **Wetter-Integration** – Aktuelle Wetterdaten via `wttr.in` in jedem Commit
- **Organisierte Struktur** – Separate Verzeichnisse für einfache Verwaltung und Löschung

## 📁 Skripte

```bash
autocommit/
├── autocommit-daily.sh   # Hauptskript - Tägliche Commits mit Wetter
├── autocommit-bit.sh     # Back In Time - Retroactive Commits
├── autocommit-matrix.sh  # Commit-Matrix - SARBS Pixelart in GitHub
└── daily/                # Wetterdaten organisiert nach JJJJ-KW-Tag
```

## 👤 Workflow: Root vs. autocommit

Der **autocommit**-Nutzer hat **keine sudo-Rechte** – das ist Absicht und erhöht die Sicherheit.

**Regel:** Alle Befehle werden **direkt als autocommit-Nutzer** ausgeführt. Nur Operationen, die Root-Zugriff benötigen (Dateien außerhalb von `/home/autocommit`), werden als Root **für** den autocommit-Nutzer ausgeführt.

### Als Root einloggen und zu autocommit wechseln

```bash
# Einloggen als Root (z.B. per SSH)
ssh root@dein-server

# Zu autocommit wechseln (mit Login-Umgebung)
su - autocommit
```

`su -` lädt die komplette Umgebung des autocommit-Nutzers (`$HOME`, `$PATH`, etc.). Das ist wichtig, damit die Skripte korrekt funktionieren. `su -` benötigt keine sudo-Rechte – Root darf immer zu jedem Benutzer wechseln.

### Wann als Root, wann als autocommit?

| Aufgabe                           | Als                            |
|-----------------------------------|--------------------------------|
| Paketinstallation (`apt install`) | Root                           |
| SSH-Schlüssel generieren          | Root (für autocommit)          |
| Repository klonen                 | Root (dann `chown`)            |
| Cronjob einrichten                | Root (`crontab -u autocommit`) |
| Skript manuell testen             | autocommit                     |
| Git-Log prüfen                    | autocommit                     |
| Dateien im Repo ansehen           | autocommit                     |

### Wichtig: Berechtigungen nach Root-Operationen

Jede Git-Operation als Root (z.B. `git pull`) setzt Berechtigungen auf Root zurück. Danach **immer** Berechtigungen korrigieren:

```bash
chown -R autocommit:autocommit /home/autocommit/autocommit/.git
```

**Besser:** Git-Operationen als Root mit dem expliziten SSH-Key ausführen:
```bash
GIT_SSH_COMMAND="ssh -i /home/autocommit/.ssh/id_ed25519_autocommit" git -C /home/autocommit/autocommit pull
```

---

## ⚡ Installation

### Voraussetzungen (als Root)

```bash
apt install git curl cron
```

### Autocommit-Nutzer erstellen

```bash
adduser --disabled-password autocommit
```

### SSH-Schlüssel generieren (als Root)

Separierten Schlüssel nur für autocommit – überschreibt keine bestehenden Schlüssel:

```bash
# .ssh Verzeichnis erstellen
mkdir -p /home/autocommit/.ssh
chown autocommit:autocommit /home/autocommit/.ssh

# Schlüssel generieren
ssh-keygen -t ed25519 -f /home/autocommit/.ssh/id_ed25519_autocommit -C "autocommit@server" -N ""

# Berechtigungen setzen
chmod 700 /home/autocommit/.ssh
chmod 600 /home/autocommit/.ssh/id_ed25519_autocommit
chown autocommit:autocommit /home/autocommit/.ssh/id_ed25519_autocommit
```

### SSH-Config erstellen (als Root)

Für den autocommit-Nutzer **und** für Root (zur Administration):

```bash
# Config für autocommit-Nutzer
cat > /home/autocommit/.ssh/config << EOF
Host codeberg.org
    HostName codeberg.org
    User git
    IdentityFile ~/.ssh/id_ed25519_autocommit

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_autocommit
EOF
chmod 600 /home/autocommit/.ssh/config
chown autocommit:autocommit /home/autocommit/.ssh/config

# Config für Root (identisch, für Admin-Aufgaben)
cat > /root/.ssh/config << EOF
Host codeberg.org
    HostName codeberg.org
    User git
    IdentityFile /home/autocommit/.ssh/id_ed25519_autocommit

Host github.com
    HostName github.com
    User git
    IdentityFile /home/autocommit/.ssh/id_ed25519_autocommit
EOF
chmod 600 /root/.ssh/config
```

### Deploy Keys eintragen

Öffentlichen Schlüssel anzeigen:

```bash
cat /home/autocommit/.ssh/id_ed25519_autocommit.pub
```

Zu beiden Remotes als **Deploy Key** hinzufügen (repo-spezifisch, nicht Account-weit):

- **Codeberg:** Repo → Settings → Deploy Keys → Add deploy key
- **GitHub:** Repo → Settings → Deploy keys → Add deploy key → **"Allow write access"** anhaken

### SSH Host Keys akzeptieren

```bash
ssh-keyscan codeberg.org github.com >> /home/autocommit/.ssh/known_hosts
chown autocommit:autocommit /home/autocommit/.ssh/known_hosts
chmod 644 /home/autocommit/.ssh/known_hosts

# Auch für Root
ssh-keyscan codeberg.org github.com >> /root/.ssh/known_hosts
chmod 644 /root/.ssh/known_hosts
```

### Repository klonen (als Root)

```bash
git clone ssh://git@codeberg.org/Sergius/autocommit.git /home/autocommit/autocommit
chown -R autocommit:autocommit /home/autocommit/autocommit
```

### Git-Identität setzen (als Root)

```bash
git -C /home/autocommit/autocommit config user.name "Git Nutzerame"
git -C /home/autocommit/autocommit config user.email "github@adresse.com"
chown autocommit:autocommit /home/autocommit/autocommit/.git/config
```

### GitHub als zweiten Push hinzufügen (als Root)

```bash
# Safe Directory für Root
git config --global --add safe.directory /home/autocommit/autocommit

# GitHub als zweite Push-URL
git -C /home/autocommit/autocommit remote set-url --add --push origin ssh://git@github.com/Sergi-us/autocommit.git
```

### Cronjob einrichten (als Root)

```bash
crontab -u autocommit -e
```

```
@daily HOME=/home/autocommit PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /home/autocommit/autocommit/autocommit-daily.sh >> /home/autocommit/autocommit.log 2>&1
```

> **Wichtig:** Cron hat eine minimale Umgebung. `HOME` und `PATH` müssen explizit gesetzt werden, sonst finden die Skripte ihre Dateien und Befehle nicht. Das Logfile (`>> ... 2>&1`) hilft bei der Fehlersuche.

## 🔧 Admin-Aufgaben

### Als Root (für autocommit)

Git-Operationen als Root mit dem expliziten SSH-Key:
```bash
GIT_SSH_COMMAND="ssh -i /home/autocommit/.ssh/id_ed25519_autocommit" git -C /home/autocommit/autocommit pull
```

Oder als Alias:
```bash
alias gitac='GIT_SSH_COMMAND="ssh -i /home/autocommit/.ssh/id_ed25519_autocommit" git -C /home/autocommit/autocommit'
```

**Nach jeder Root-Operation Berechtigungen korrigieren:**
```bash
chown -R autocommit:autocommit /home/autocommit/autocommit/.git
```

### Als autocommit-Nutzer

```bash
su - autocommit
```

Dann alle Befehle normal ausführen:
```bash
git -C ~/autocommit log --oneline -5
git -C ~/autocommit pull
```

## ✅ Testen

Skript manuell ausführen (als Root):
```bash
su -s /bin/sh -c '/home/autocommit/autocommit/autocommit-daily.sh' autocommit
```

Oder als autocommit-Nutzer:
```bash
su - autocommit
~/autocommit/autocommit-daily.sh
```

Erwartete Ausgabe:
```
Erstellt X Einträge für YYYY-WW-T
```

Prüfen ob Commits angekommen sind:

```bash
# Lokal
su -s /bin/sh -c 'git -C /home/autocommit/autocommit log --oneline -5' autocommit
ls /home/autocommit/autocommit/daily/

# Codeberg
https://codeberg.org/Sergius/autocommit/commits

# GitHub
https://github.com/Sergi-us/autocommit/commits
```

## 🛠️ Funktionsweise

1. **autocommit-daily.sh** – Zufallszahl (0-5), bei 0 keine Commits
2. **autocommit-bit.sh** – Zufallszahl (0-20), bei 0 keine Commits
3. Bei >0 → entsprechende Anzahl Commits mit:
   - Unix-Zeitstempel
   - Aktuellen Wetterdaten von `wttr.in`
   - Eintrag in `daily/JJJJ-KW-Tag.txt`
4. Automatisch `git add`, `commit` und `push` zu beiden Remotes

## 📄 Lizenz

MIT

## 🤝 Credits

- **[SARBS](https://codeberg.org/Sergius/SARBS)** - Suckless Auto-Rice Bootstrapping Scripts
- **[wttr.in](https://wttr.in/)** - Wetterdienst

---

**📧 Kontakt**:
- [Codeberg Issues](https://codeberg.org/Sergius/autocommit/issues)
- [GitHub Issues](https://github.com/Sergi-us/autocommit/issues) (Mirror)
- [SARBS Homepage](https://sarbs.xyz/kontakt/)
