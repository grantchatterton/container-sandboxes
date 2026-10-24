# Environment

## Available Tools

- node, npm, npx
- bun, bunx
- git
- jq
- rg
- fdfind

## Constraints

- Runs as non-root `node`; no privilege escalation, capabilities dropped.
- Current project directory is bind-mounted read-write at the same path as on the host.
- Root filesystem is read-only. Writable locations are the project, `/tmp`, and explicitly mounted agent state/cache directories. `$HOME` itself is not generally writable.
- `/tmp` is ephemeral, limited to 512 MiB, and mounted `noexec,nosuid,nodev`. Native executables cannot run from there.
- If tooling needs executable temporary files, use a temporary gitignored directory under the project, set TMPDIR for that command and clean up afterward.
- Prefer project-local dependencies.
