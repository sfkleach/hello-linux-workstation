# hello-linux-workstation

Sets up my Linux Mint workstation from a fresh install, and doubles as my
dotfiles repo.

## Quick start

```bash
git clone https://github.com/sfkleach/hello-linux-workstation.git
cd hello-linux-workstation
./setup.sh
```

`setup.sh` runs every script under `modules/` in order. Each module is
**idempotent** — it checks what's already installed and only does the work
that's missing, so it's safe to re-run any time (e.g. after adding a new
module, or on a machine that already has some tools installed).

## What it sets up

| Module | Installs |
|--------|----------|
| `05-folders.sh` | Standard top-level folders: `~/org`, `~/com`, `~/projects` |
| `10-essentials.sh` | System upgrade, `build-essential`, `curl`, `wget`, `jq`, `htop`, `tree`, `ripgrep`, `fd-find`, `bat` |
| `15-just.sh` | `just`, via its official prebuilt-binary installer, to `~/.local/bin` |
| `20-git.sh` | `git` + global config, SSH key (`~/.ssh/id_ed25519`), `lazygit` |
| `30-python.sh` | `uv` |
| `40-golang.sh` | Go (official tarball, `/usr/local/go`) |
| `50-rust.sh` | Rust via `rustup` |
| `60-node.sh` | `fnm` + Node LTS (only needed to install the Claude Code CLI below) |
| `70-vscode.sh` | VS Code (extensions are managed manually, not by this script) |
| `80-podman.sh` | Podman + `podman-compose` |
| `90-claude-code.sh` | Claude Code CLI (`npm install -g @anthropic-ai/claude-code`) |
| `98-keybase.sh` | Keybase, from the official `.deb`, then `run_keybase` to finish setup |
| `99-smartgit.sh` | SmartGit, from the official tarball, unpacked to `/opt/smartgit`, with its desktop menu item |

`just` defaults to the prebuilt-binary install. To build it from source
instead, `cargo install just` works fine once `50-rust.sh` has run.

`98-keybase.sh` and `99-smartgit.sh` run last on purpose: both depend on
third-party download URLs outside apt, which have already proven flakier
in practice than a normal `apt install` (SmartGit's old apt-repo approach
hit a 404 on syntevo's published key). `run_keybase` opens the app for
interactive account setup — that last step isn't scriptable. SmartGit's
version is a hardcoded string in its module — bump `SMARTGIT_VERSION`
from [the download page](https://www.syntevo.com/smartgit/download/)
when you want a newer release. If a module fails, `setup.sh` prints a
warning and keeps going rather than aborting the whole run — re-run
`./setup.sh` (or just the one failed module) once it's fixed.

## Skipping the apt update/upgrade of already-installed packages

Every `apt install` call goes through `apt_install_if_missing` in
`lib/common.sh`, which checks `command -v` for each package's "signature"
command before installing it — so re-running the script never re-installs
something that's already there. Most packages share their binary name
(`git` → `git`), but a few don't, so the call sites spell those out with a
`package:command` override, e.g.:

```bash
apt_install_if_missing ripgrep:rg fd-find:fdfind bat:batcat
```

Add new packages the same way if you extend a module.

## Shell integration

`setup.sh` appends one `source` line to `~/.bashrc` (guarded so it's only
added once) pointing at `dotfiles/bashrc.d/path.sh`, which wires up `PATH`
for cargo, Go, `uv`, and `fnm`. Start a new shell (or `source ~/.bashrc`)
after the first run to pick it up.

## Running a single module

Since modules are just standalone scripts, you can re-run one on its own:

```bash
./modules/50-rust.sh
```
