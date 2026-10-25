# Environment

## Available Tools

- node, npm, npx
- bun, bunx
- git
- jq
- python3
- rg
- shellcheck
- fdfind

## Constraints

- Runs as non-root `node`; no privilege escalation, capabilities dropped.
- Root filesystem is read-only. Writable locations are the project, `/tmp`, and explicitly mounted agent state/cache directories.
- Prefer project-local dependencies.
