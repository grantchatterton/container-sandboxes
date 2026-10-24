# container-sandboxes

`sbx` is a bash script that builds and runs Podman sandboxes. See README.md.

- `sbx`: CLI commands (`run`, `update`, `list`), shared sandbox defaults (`load_sandbox`), and Podman build/run argument assembly.
- `sandboxes/<name>/sandbox.sh`: per-sandbox run settings, sourced by `load_sandbox`. Only set `sandbox_*` variables there; a new directory is discovered automatically.
- `base/Dockerfile` defines the shared `base` stage (and an `installer` stage for `curl | bash` installs); `sandboxes/<name>/Dockerfile` builds `FROM base` and its last stage is the image. `sbx` resolves both from its own directory (following symlinks), concatenates them, and passes the result to Podman over stdin.
- `base/append-system-prompt.md` lists CLI tools from the shared base and short sandbox env gotchas. Claude and Pi pass it via `--append-system-prompt` in `sandbox_agent_args` (Cursor has no such flag). Keep tools/env notes in sync when base packages or hardening change.
- Before finishing a change, update README.md (and any other docs) when behavior, packages, CLI, or layout change. Run `bash -n sbx` and `shellcheck -x -s bash sbx sandboxes/*/sandbox.sh` if available. Keep arguments in arrays; the script runs under `set -euo pipefail`.
- Always quote variable expansions and command substitutions (`"$var"`, `"${arr[@]}"`, `"$(cmd)"`), including in `sandboxes/*/sandbox.sh`. Leave one unquoted only where quoting changes meaning (a regex after `=~`, a glob pattern after `==`/`!=` or in `case`), and say why in a comment.
