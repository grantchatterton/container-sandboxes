# container-sandboxes

`sbx` is a bash script that builds and runs Podman sandboxes. See README.md.

- `sbx`: CLI commands (`run`, `update`, `list`), sandbox definitions (`load_sandbox`), and Podman build/run argument assembly.
- The root `Dockerfile` has a shared base and per-agent targets. `sbx` reads it from its own directory (resolving symlinks) and passes it to Podman over stdin.
- Before finishing a change, run `bash -n sbx` and `shellcheck sbx` if available. Keep arguments in arrays and quote expansions; the script runs under `set -euo pipefail`.
