# 💾 BakPak
![GitHub License](https://img.shields.io/github/license/foiovituh/bakpak)
![GitHub Release](https://img.shields.io/github/v/release/foiovituh/bakpak)

> 🧠 A lightweight Bash script for timestamped directory backups — easy to automate with cron.

![Image](https://github.com/user-attachments/assets/dc80cff7-71da-46af-9371-8802f7f191b3)

## 📦 Installation
```bash
git clone https://github.com/foiovituh/bakpak.git
cd bakpak
chmod +x bakpak.sh
sudo ln -s "$PWD/bakpak.sh" /usr/local/bin/bakpak
```

## 🚀 Usage
### Required:
```bash
-f <path>    Directory to back up (must be readable)
-t <path>    Directory to store the compressed archive (must be writable)
```

### Optional:
```bash
-v           Show script version
-h           Show a help message
-u           Uncompressed mode - create a .tar without gzip compression
-d           Dry-run mode — no backups will be created, only displayed
-c <expr>    Schedule backup as a cron job using the specified cron expression
```

### Examples:

- Basic backup (compressed):
```bash
bakpak -f ~/Documents -t /mnt/docs_backup
```

- Dry-run (no files created):
```bash
bakpak -f ~/Tests -t /mnt/backup_simulations -d
```

- Cron job (1st day of month at 17:00):
```bash
bakpak -f /home/user/folder -t /mnt/backups -c "0 17 1 * *"
```

- Uncompressed backup with custom name:
```bash
bakpak -f ~/projects/president -t /mnt/d/band -p uncompressed_site_project -u
```

## ⏰ Cron Scheduling
Use the `-c` option with a valid [cron expression](https://crontab.guru) (e.g., `0 17 1 * *`) to schedule automatic backups.

Make sure both `-f` (from) and `-t` (to) arguments use **absolute paths** (starting with `/`) so cron runs correctly.

## 🔍 Logs
All backup activity is automatically logged:

| Type       | Path                                      |
|------------|-------------------------------------------|
| ✅ Success | `~/.bakpak/logs/successes.log`            |
| ❌ Error   | `~/.bakpak/logs/errors.log`               |

## ⭐ Support the Project
If you like this project or find it useful, please give it a star! It helps with visibility and motivates continued development.

## 📄 License
Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.
