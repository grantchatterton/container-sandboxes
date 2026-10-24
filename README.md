# container-sandboxes

`sbx` builds and runs hardened Podman containers for Claude Code, Cursor Agent,
and Pi. Each sandbox is a `sandboxes/<name>/` directory with a
`Dockerfile` (built on the shared `base/Dockerfile`) and a `sandbox.sh` of run
settings.
Requires Linux, Bash 4.4+, Podman (preferably rootless), and `realpath`.
CPU/memory enforcement requires working cgroup delegation (normally cgroups v2).
If `krun` is on `PATH`, runs use the krun microVM runtime.

```sh
ln -sf "$PWD/sbx" ~/.local/bin/sbx   # install from this checkout
sbx list                           # claude, cursor, pi
sbx run pi                         # cwd mounted at the same path
sbx run cursor -- 'explain this project'
sbx run claude -- 'explain this project'
sbx update claude                  # refresh base images and installed agent
sbx update all                     # refresh every sandbox
sbx --help
```

The script follows symlinks to find `base/` and `sandboxes/`. Keep them
together; install a symlink rather than copying the script elsewhere. Run from the project
you want the agent to edit. Agent flags and prompts must follow `--`.

## Images and updates

Images are tagged `localhost/<name>-sandbox:latest`. `run` builds a missing image
and otherwise reuses it. `update` pulls base images and invalidates agent install
layers using `CACHE_BUST`, leaving other layers cacheable. Neither operation
erases persistent agent state. A running container keeps its existing image.

Builds concatenate `base/Dockerfile` and `sandboxes/<name>/Dockerfile` and send
the result on stdin with an empty temporary build context, never your project.
The last stage of the sandbox's Dockerfile is the image, and the `base` stage
is shared between sandboxes through the build cache. Builds pass the host's
`node --version` and `bun --version` as `NODE_VERSION` and `BUN_VERSION` build
arguments (stripping Node's leading `v`). If either runtime is unavailable or
its version command fails or returns empty output, that runtime uses its
default in `base/Dockerfile`. Run `sbx update <name>` (or `sbx update all`) to
pick up host version changes in an existing image. The shared base includes
Node.js, npm, Bun/bunx, Bash, CA certificates, fd-find, Git, jq, Python 3, ripgrep,
ShellCheck, and shfmt. All final images run as the non-root `node` user. Claude and Cursor Agent install in separate build
stages; Cursor Agent ships its own Node binary under `/opt/cursor-agent`.

## Runtime security and writable storage

Every run uses:

- All Linux capabilities dropped and `no-new-privileges` enabled.
- A read-only root filesystem, with automatic Podman tmpfs mounts disabled.
- A 512 MiB ephemeral `/tmp` with `noexec,nosuid,nodev`.
- Limits of **4 CPUs**, **8192m RAM**, **2048 processes**, and no additional swap.
  Defaults live in `load_sandbox` (`sandbox_cpus`, `sandbox_memory_mib`); a
  sandbox's `sandbox.sh` can override them.
- A private user namespace (`keep-id`) mapping your UID/GID to container user
  1000:1000, so project files remain owned by you on the host.
- Podman's default seccomp policy and network isolation (no host namespaces or
  container-engine socket). Outbound network access remains enabled for APIs
  and downloads; this is **not** a network/exfiltration sandbox.
- An ephemeral container (`--rm`), stdin forwarding, and a TTY only when both
  stdin and stdout are terminals. Agent exit status is returned to the caller.
- The krun runtime and matching CPU/RAM annotations when `krun` is installed.

The **current directory is mounted read-write at the same host path** inside the
container (workdir matches). Choose a narrow project directory: do not run from
your home or a directory containing unrelated secrets. Host `/` is rejected, and
the directory must be a subdirectory of `/home/grant/Projects` (that directory
itself is not enough). Paths containing `:` or `,` are rejected to avoid
ambiguous mount syntax.
If `~/.bunfig.toml` exists, it is mounted read-only into the container.
If `~/.agents/skills` exists, it is mounted read-only at the same path.

Agent state persists in named volumes (`:U` so ownership matches the container
user):

| Sandbox | Volume | Container path |
| --- | --- | --- |
| claude | `claude-home` | `/home/node/.claude` |
| pi | `pi-agent-home` | `/home/node/.pi/agent` |

These writable volumes hold authentication, config, sessions, and caches. The
claude sandbox sets `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1`, so Claude Code does not
save session transcripts or prompt history (`--resume`/`--continue` have nothing
to load). Log
in through the agent inside the sandbox. Host environment variables (including
API keys), SSH keys, cloud credentials, sockets, and dotfiles are not forwarded.

Cursor Agent has no named volume. `CURSOR_API_KEY` is injected from the Podman
secret `cursor_api_key` (`--secret cursor_api_key,type=env,target=CURSOR_API_KEY`).
Create it with `podman secret create cursor_api_key` (the file or stdin is the
key). Its writable state lives on tmpfs mounts at `/home/node/.config/cursor`
and `/home/node/.cursor` and is discarded when the container exits.
Git name/email are forwarded if configured; the host `.gitconfig` is not
mounted. Projects can still contain their own secrets or Git configuration, so
inspect untrusted repositories before running an agent. Read-only root does not
make writable projects or persisted agent state immutable, and containers share
the host kernel (unless krun provides a microVM): use a dedicated VM for
stronger isolation from hostile workloads.

To erase an agent's saved state, stop its containers and explicitly remove its
volume, e.g. `podman volume rm pi-agent-home` (destructive).

## Customization and checks

`load_sandbox` sets shared defaults (image tag, Dockerfile, CPU/memory limits,
and empty `sandbox_agent_args`, `sandbox_build_opts`, `sandbox_run_opts` arrays),
then sources `sandboxes/<name>/sandbox.sh` to adjust them. Put env, volumes,
mounts, tmpfs, secrets, and other `podman run` extras in `sandbox_run_opts`.
`sandbox.sh` files should only set `sandbox_*` variables; keep arguments as
array elements, not shell snippets. Raw options can weaken the security
baseline; prefer changing only what you need.

To add an agent, create `sandboxes/<name>/` (names are lowercase letters,
digits, `-`, `_`) with a `sandbox.sh` and a `Dockerfile` whose last stage is
`FROM base`. Declare `ARG CACHE_BUST=1` just before the agent install step so
`update` reinstalls it. Don't reuse the stage names `bun` or `base`. `sbx list`
and help output discover sandboxes from that directory. To change shared tools,
edit `base/Dockerfile` and update each affected sandbox.

```sh
bash -n sbx
shellcheck -x -s bash sbx sandboxes/*/sandbox.sh   # when installed
```
