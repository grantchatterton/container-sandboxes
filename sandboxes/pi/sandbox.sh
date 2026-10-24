# Pi. Sourced by sbx's load_sandbox; only set sandbox_* variables.
sandbox_run_opts+=(
  --env PI_OFFLINE=1
  --env PI_TELEMETRY=0
  --volume "pi-agent-home:/home/node/.pi/agent:U"
)
sandbox_agent_args+=(
  --no-session
)
