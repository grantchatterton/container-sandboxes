# Pi. Sourced by sbx's load_sandbox; only set sandbox_* variables.
sandbox_run_opts+=(
  --env PI_OFFLINE=1
  --env PI_TELEMETRY=0
  --volume "pi-agent-home:/home/node/.pi/agent:U"
  --tmpfs "/home/node/.npm:rw,noexec,nosuid,nodev,size=512m,mode=0700,U"
  --tmpfs "/home/node/.config/cursor:rw,noexec,nosuid,nodev,size=1m,mode=0700,U"
  --tmpfs "/home/node/.cursor:rw,noexec,nosuid,nodev,size=512m,mode=0700,U"
  --secret "cursor_api_key,type=env,target=CURSOR_API_KEY"
)

sandbox_agent_args+=(
  --append-system-prompt "$(cat -- "$SCRIPT_DIR/base/append-system-prompt.md")"
)

# shellcheck disable=SC2154
if [[ "$sandbox_empty_workspace" == true ]]; then
  sandbox_agent_args+=(--no-session)
fi
