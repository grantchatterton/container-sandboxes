# container-sandboxes

`sbx` builds and runs hardened Podman sandboxes for Claude Code, Cursor Agent, and Pi.

**Requires:** Linux, Bash 4.4+, Podman (rootless preferred), `realpath`. Uses krun when available.

```sh
ln -sf "$PWD/sbx" ~/.local/bin/sbx
sbx list
sbx run pi                         # mount cwd read-write at the same path
sbx run pi --cpus 2 --memory 4096  # override limits (default 4 CPUs, 8192 MiB)
sbx run pi --empty                 # disposable /workspace, no cwd mount
sbx run cursor -- 'explain this project'
sbx update claude                  # refresh image / agent
sbx update all
```

Install via symlink (not copy) so `base/` and `sandboxes/` resolve next to the script. `sbx` flags go before `--`; agent args after.

## Layout

| Path | Role |
| --- | --- |
| `sbx` | CLI (`run`, `update`, `list`) |
| `base/Dockerfile` | Shared base (+ `installer` stage) |
| `sandboxes/<name>/Dockerfile` | Image (`FROM base`) |
| `sandboxes/<name>/sandbox.sh` | Run settings (`sandbox_*` vars only) |

Images tag as `localhost/<name>-sandbox:latest`. Builds concatenate base + sandbox Dockerfiles over stdin (empty context). Shared base has Node, npm, Bun, Bash, Git, jq, ripgrep, fd-find.

## Security (brief)

- Dropped caps, no-new-privileges, read-only root, ephemeral `/tmp`
- Private user ns (`keep-id`); network on for APIs (not an exfil sandbox)
- Cwd must be under `/home/grant/Projects` (not `/` or home); `--empty` works anywhere
- Agent state: named volumes (`claude-home`, `pi-agent-home`) or tmpfs (cursor); Cursor needs `podman secret create cursor_api_key`
- Host env/SSH/credentials are not forwarded

## Add a sandbox

Create `sandboxes/<name>/` with `sandbox.sh` and a Dockerfile ending `FROM base`. Use `FROM installer` for curl installs; declare `ARG CACHE_BUST=1` before the install step. Avoid stage names `bun`, `installer`, `base`.

```sh
bash -n sbx
shellcheck -x -s bash sbx sandboxes/*/sandbox.sh
```
