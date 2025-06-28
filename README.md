# BakPak 💾
![GitHub License](https://img.shields.io/github/license/foiovituh/bakpak)

![Image](https://github.com/user-attachments/assets/cc4d443d-f1f2-4a34-8b59-f073e5ed0321)

A minimal Bash utility that turns any directory into a timestamped, compressed archive.

## Summary 📝
- [BakPak 💾](#bakpak-)
  - [Summary 📝](#summary-)
  - [Features ✨](#features-)
  - [Confirmed Working On ✅](#confirmed-working-on-)
  - [Installation 📦](#installation-)
  - [Usage 🚀](usage-)
  - [Automation ⏰](#automation-)
  - [Do you want help me? 👥](#do-you-want-help-me-)
  - [License 🏳️](#license-️)

## Features ✨
* **Portable** (only relies on `tar`, `gzip` and `readlink`).
* **Safety first** (sanity‑checks that source *and* destination are accessible).
* **Human‑readable logging** (ISO‑8601 timestamps).
* **Zero‑config** (drop the script anywhere and run).

## Confirmed Working On ✅
| Component   | Version / Notes                        |
| ----------- | -------------------------------------- |
| **Bash**    | 5.2.21 (GNU)                           |
| **GNU tar** | 1.35                                   |
| **gzip**    | 1.12                                   |
| **OS**      | Ubuntu 24.04 (kernel 6.8.0-60-generic) |

## Installation 📦
```bash
# 1. Clone the repository
$ git clone https://github.com/foiovituh/bakpak.git
$ cd bakpak

# 2. Make the script executable
$ chmod +x bakpak.sh

# 3 Install system‑wide
$ sudo ln -s "$PWD/bakpak.sh" /usr/local/bin/bakpak
```

## Usage 🚀
```bash
bakpak <from> <to>
```

* **from** must be a readable directory.
* **to**   must be a writable directory.

Example:

```bash
$ bakpak /home/president/Documents /mnt/backups
2025-06-22T14:55:03 | Backup created at: /mnt/backups/
```

## Automation ⏰
Running a monthly backup at 5 PM on the 1st day of every month with `cron`:

```cron
0 17 1 * * /usr/local/bin/bakpak /home/president/Documents /mnt/backups
```

## Do you want help me? 👥
If you have any ideas or wish to contribute to the project, contact me on X (<a href="https://x.com/ohtoaki" target="_blank">@ohtoaki</a>) or send me a pull request :)

## License 📄
Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.
