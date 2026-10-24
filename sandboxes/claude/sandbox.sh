# Claude Code. Sourced by sbx's load_sandbox; only set sandbox_* variables.
sandbox_run_opts+=(
  --env DISABLE_AUTOUPDATER=1
  --env CLAUDE_CONFIG_DIR=/home/node/.claude
  --env CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
  --volume "claude-home:/home/node/.claude:U"
)
