# Cursor Agent. Sourced by sbx's load_sandbox; only set sandbox_* variables.
# State lives on tmpfs and is discarded on exit; the API key comes from the
# Podman secret cursor_api_key.
sandbox_run_opts+=(
  --tmpfs "/home/node/.config/cursor:rw,noexec,nosuid,nodev,size=1m,mode=0700,U"
  --tmpfs "/home/node/.cursor:rw,noexec,nosuid,nodev,size=512m,mode=0700,U"
  --secret "cursor_api_key,type=env,target=CURSOR_API_KEY"
)
sandbox_agent_args+=(
  --trust
  --yolo
  --model cursor-grok-4.5-high-fast
)
