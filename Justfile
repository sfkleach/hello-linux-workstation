# List available recipes.
default:
    @just --list

# Run (or re-run) the full setup — safe after a partial failure, since every module skips work already done.
setup:
    ./setup.sh

# Alias for `setup` — use this after a module failed partway through a run.
retry: setup

# Run a single module by name or number, e.g. `just module rust` or `just module 50`.
module name:
    #!/usr/bin/env bash
    set -euo pipefail
    match=$(ls modules/*"{{ name }}"*.sh 2>/dev/null | head -1)
    if [[ -z "$match" ]]; then
        echo "No module matching '{{ name }}'." >&2
        exit 1
    fi
    echo "Running $match"
    bash "$match"

# List all modules in run order.
list:
    @ls modules/*.sh | xargs -n1 basename

# Syntax-check setup.sh and every module (no changes made).
check:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in setup.sh lib/*.sh modules/*.sh; do
        bash -n "$f" && echo "OK: $f"
    done

# Report any hardcoded tool versions (Go, SmartGit, Proton Mail) that are behind upstream. Read-only.
versions:
    @./scripts/check-versions.sh
