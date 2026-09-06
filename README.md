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

## Using `just` (after the first run)

The very first run has to be `./setup.sh` directly — `just` itself doesn't
exist yet on a fresh machine (it's installed by `15-just.sh`). Once that's
done, `Justfile` is there mainly to document and make convenient the
commands you'd otherwise have to remember:

```bash
just setup          # re-run everything (same as ./setup.sh)
just retry          # alias for the above, for after a module failed
just module rust    # re-run just one module, by name or number
just list           # show every module in run order
just check          # bash -n syntax-check everything, no changes made
just versions       # report which hardcoded tool versions are behind upstream
```

## What it sets up

| Module | Installs |
|--------|----------|
| `05-folders.sh` | Standard top-level folders: `~/org`, `~/com`, `~/projects` |
| `10-essentials.sh` | System upgrade (once per day), `build-essential`, `curl`, `wget`, `jq`, `htop`, `tree`, `ripgrep`, `fd-find`, `bat` |
| `15-just.sh` | `just`, via its official prebuilt-binary installer, to `~/.local/bin` |
| `20-git.sh` | `git` + global config, SSH key (`~/.ssh/id_ed25519`), `lazygit` |
| `30-python.sh` | `uv` |
| `40-golang.sh` | Go (official tarball, `/usr/local/go`) |
| `50-rust.sh` | Rust via `rustup` |
| `60-node.sh` | `fnm` + Node LTS (only needed to install the Claude Code CLI below) |
| `70-vscode.sh` | VS Code (extensions are managed manually, not by this script) |
| `73-keepassxc.sh` | KeePassXC (Mint's native package) |
| `75-chromium.sh` | Chromium (Mint's native package, not Ubuntu's Snap wrapper) |
| `76-typora.sh` | Typora, via its own apt repo |
| `77-protonmail.sh` | Proton Mail desktop app, from the official `.deb` |
| `78-balena-etcher.sh` | balenaEtcher, from the official Linux zip, unpacked to `/opt/balenaEtcher` |
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

`77-protonmail.sh` follows the same pattern as SmartGit: Proton doesn't
publish an apt repo for the desktop app, just versioned `.deb` downloads,
so the version is a hardcoded `PROTONMAIL_VERSION` string — bump it from
[the download page](https://proton.me/mail/download) if the module
reports it can't fetch the current one. (An earlier attempt used Proton
Mail Bridge instead, but it kept breaking itself via its own
auto-updater, so it's been dropped in favor of the desktop app.)

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

## Checking for stale hardcoded versions

Most tools install "whatever is currently latest" automatically (rustup,
uv, fnm, the `just`/lazygit/balenaEtcher installers all check upstream
themselves). Three don't, because they have no real update API and are
pinned to a version string that has to be bumped by hand: Go
(`GO_VERSION` in `40-golang.sh`), SmartGit (`SMARTGIT_VERSION` in
`99-smartgit.sh`), and Proton Mail (`PROTONMAIL_VERSION` in
`77-protonmail.sh`).

`scripts/check-versions.sh` (or `just versions`) checks those three
against upstream and reports any that are behind — Go via its official
JSON API, SmartGit and Proton Mail by best-effort scraping of their
download pages, since neither publishes an API. It's read-only: it never
installs or edits anything, just prints a report. A `latest=?` result
means the scrape didn't find a match (page changed, or blocked) — check
the download page by hand in that case.
