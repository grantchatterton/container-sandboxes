# syntax=docker/dockerfile:1
ARG NODE_VERSION=24.22.1
ARG BUN_VERSION=1.4.4

FROM docker.io/oven/bun:${BUN_VERSION}-slim AS bun

# ---------------------------------------------------------------------------
# Base
# ---------------------------------------------------------------------------
FROM docker.io/library/node:${NODE_VERSION}-trixie-slim AS base
RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates fd-find git jq ripgrep shellcheck shfmt \
  && rm -rf /var/lib/apt/lists/*
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
RUN ln -sf bun /usr/local/bin/bunx
WORKDIR /workspace
USER node

# ---------------------------------------------------------------------------
# Claude
# ---------------------------------------------------------------------------
FROM docker.io/library/debian:trixie-slim AS claude-installer
RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*
ARG CACHE_BUST=1
RUN curl -fsSL https://claude.ai/install.sh | bash \
  && install -D -m 755 /root/.local/bin/claude /out/claude

FROM base AS claude
COPY --from=claude-installer /out/claude /usr/local/bin/claude
ENTRYPOINT ["claude"]

# ---------------------------------------------------------------------------
# Pi
# ---------------------------------------------------------------------------
FROM base AS pi
USER root
ARG CACHE_BUST=1
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent
USER node
ENTRYPOINT ["pi"]

# ---------------------------------------------------------------------------
# Cursor Agent
# The installer drops a versioned tree (script plus its own Node binary) under
# $HOME and symlinks ~/.local/bin/agent. Copy that tree to a stable path.
# ---------------------------------------------------------------------------
FROM docker.io/library/debian:trixie-slim AS cursor-installer
RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*
ARG CACHE_BUST=1
RUN curl -fsSL https://cursor.com/install | bash \
  && cp -a "$(dirname -- "$(readlink -f /root/.local/bin/agent)")" /opt/cursor-agent

FROM base AS cursor
COPY --from=cursor-installer /opt/cursor-agent /opt/cursor-agent
USER root
RUN ln -sf /opt/cursor-agent/cursor-agent /usr/local/bin/agent \
  && ln -sf /opt/cursor-agent/cursor-agent /usr/local/bin/cursor-agent
USER node
ENTRYPOINT ["agent"]
