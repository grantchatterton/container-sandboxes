# Pi. Sourced by sbx's load_sandbox; only set sandbox_* variables.
sandbox_run_opts+=(
  --env PI_OFFLINE=1
  --env PI_TELEMETRY=0
  --volume "pi-agent-home:/home/node/.pi/agent:U"
  --tmpfs "/home/node/.npm:rw,noexec,nosuid,nodev,size=512m,mode=0700,U"
)
sandbox_agent_args+=(
  --no-session
)
