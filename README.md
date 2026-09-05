# hello-linux-workstation

Automates setting up a Linux workstation from a fresh install.

## Supported distros

| Family | Package manager |
|--------|----------------|
| Debian / Ubuntu | `apt` |
| Fedora / RHEL | `dnf` |
| Arch Linux | `pacman` |

## Quick start

```bash
git clone https://github.com/sfkleach/hello-linux-workstation.git
cd hello-linux-workstation
chmod +x setup.sh
./setup.sh
```

The script is **idempotent** — safe to re-run after a failed step or to apply updates.
